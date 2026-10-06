suppressPackageStartupMessages({
  library(tidyverse)
  library(janitor)
  library(broom)
  library(knitr)
})

options(scipen = 999)
set.seed(123)

project_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
rmd_path <- file.path(project_dir, "analysis.Rmd")
dataset_path <- file.path(project_dir, "data", "sleep_health_and_lifestyle.csv")

if (is.na(dataset_path) || !file.exists(dataset_path)) {
  stop("No se encontró data/sleep_health_and_lifestyle.csv.")
}

output_dir <- file.path(project_dir, "outputs")
fig_dir <- file.path(output_dir, "figures")
table_dir <- file.path(output_dir, "tables")
info_dir <- file.path(output_dir, "informacion")
script_dir <- file.path(output_dir, "scripts")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(info_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(script_dir, recursive = TRUE, showWarnings = FALSE)

theme_bio <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 3),
      plot.subtitle = element_text(size = base_size, margin = margin(b = 8)),
      plot.caption = element_text(size = base_size - 2, hjust = 0),
      axis.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      legend.title = element_text(face = "bold")
    )
}

paleta_trastorno <- c(
  "Sin trastorno reportado" = "#2E86AB",
  "Insomnio" = "#F18F01",
  "Apnea del sueño" = "#C73E1D"
)

paleta_imc <- c(
  "Normal" = "#4E79A7",
  "Sobrepeso" = "#F28E2B",
  "Obesidad" = "#E15759"
)

write_table <- function(x, name) {
  readr::write_csv(x, file.path(table_dir, paste0(name, ".csv")), na = "")
}

append_markdown_table <- function(lines, title, x, digits = 2) {
  c(
    lines,
    "",
    paste0("## ", title),
    "",
    capture.output(knitr::kable(x, format = "pipe", digits = digits))
  )
}

save_plot <- function(plot, filename, width = 9, height = 6) {
  ggsave(
    filename = file.path(fig_dir, filename),
    plot = plot,
    width = width,
    height = height,
    dpi = 300,
    bg = "white"
  )
}

tabla_frecuencia <- function(datos, variable, nombre_variable) {
  datos %>%
    count({{ variable }}, name = "frecuencia") %>%
    mutate(
      porcentaje = round(frecuencia / sum(frecuencia) * 100, 2),
      variable = nombre_variable
    ) %>%
    rename(categoria = {{ variable }}) %>%
    mutate(categoria = as.character(categoria)) %>%
    select(variable, categoria, frecuencia, porcentaje)
}

contar_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  riq <- q3 - q1
  limite_inferior <- q1 - 1.5 * riq
  limite_superior <- q3 + 1.5 * riq

  tibble(
    limite_inferior = as.numeric(limite_inferior),
    limite_superior = as.numeric(limite_superior),
    posibles_valores_extremos = sum(
      x < limite_inferior | x > limite_superior,
      na.rm = TRUE
    )
  )
}

resumen_cuantitativo <- function(datos, variables) {
  datos %>%
    select(all_of(variables)) %>%
    pivot_longer(
      cols = everything(),
      names_to = "variable",
      values_to = "valor"
    ) %>%
    group_by(variable) %>%
    summarise(
      n = sum(!is.na(valor)),
      media = mean(valor, na.rm = TRUE),
      mediana = median(valor, na.rm = TRUE),
      desviacion_estandar = sd(valor, na.rm = TRUE),
      minimo = min(valor, na.rm = TRUE),
      maximo = max(valor, na.rm = TRUE),
      .groups = "drop"
    )
}

sleep_raw <- read.csv(
  dataset_path,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

sleep <- sleep_raw %>%
  clean_names()

n_registros <- nrow(sleep)
n_variables <- ncol(sleep)

resumen_base <- tibble(
  indicador = c("Número de registros", "Número de variables"),
  valor = c(n_registros, n_variables)
)

diccionario_variables <- tibble(
  variable_original = c(
    "Gender", "Age", "Sleep Duration", "Quality of Sleep",
    "Physical Activity Level", "Stress Level", "BMI Category",
    "Blood Pressure", "Heart Rate", "Daily Steps", "Sleep Disorder",
    "Occupation"
  ),
  variable_en_r = c(
    "gender", "age", "sleep_duration", "quality_of_sleep",
    "physical_activity_level", "stress_level", "bmi_category",
    "blood_pressure", "heart_rate", "daily_steps", "sleep_disorder",
    "occupation"
  ),
  traduccion = c(
    "Sexo", "Edad", "Duración del sueño", "Calidad del sueño",
    "Nivel de actividad física", "Nivel de estrés", "Categoría de IMC",
    "Presión arterial", "Frecuencia cardíaca", "Pasos diarios",
    "Trastorno del sueño", "Ocupación"
  ),
  funcion_analitica = c(
    "Variable descriptiva",
    "Variable de ajuste",
    "Variable descriptiva del descanso",
    "Variable dependiente principal",
    "Variable de ajuste conductual",
    "Variable independiente principal",
    "Variable descriptiva del estado nutricional",
    "Indicador fisiológico complementario",
    "Indicador fisiológico complementario",
    "Indicador de actividad cotidiana",
    "Variable cualitativa de salud del sueño",
    "Variable sociodemográfica"
  )
)

sleep_sel <- sleep %>%
  select(
    gender,
    age,
    sleep_duration,
    quality_of_sleep,
    physical_activity_level,
    stress_level,
    bmi_category,
    blood_pressure,
    heart_rate,
    daily_steps,
    sleep_disorder,
    occupation
  ) %>%
  mutate(
    sleep_disorder_clean = case_when(
      is.na(sleep_disorder) | trimws(sleep_disorder) == "" ~ "None",
      TRUE ~ sleep_disorder
    ),
    bmi_category = case_when(
      bmi_category %in% c("Normal", "Normal Weight") ~ "Normal",
      TRUE ~ bmi_category
    )
  ) %>%
  separate(
    blood_pressure,
    into = c("systolic_bp", "diastolic_bp"),
    sep = "/",
    convert = TRUE,
    remove = FALSE
  ) %>%
  mutate(
    gender = factor(
      gender,
      levels = c("Female", "Male"),
      labels = c("Mujer", "Hombre")
    ),
    bmi_category = factor(
      bmi_category,
      levels = c("Normal", "Overweight", "Obese"),
      labels = c("Normal", "Sobrepeso", "Obesidad")
    ),
    sleep_disorder_clean = factor(
      sleep_disorder_clean,
      levels = c("None", "Insomnia", "Sleep Apnea"),
      labels = c("Sin trastorno reportado", "Insomnio", "Apnea del sueño")
    ),
    occupation = as.factor(occupation)
  )

vars_cuantitativas <- c(
  "age",
  "sleep_duration",
  "quality_of_sleep",
  "physical_activity_level",
  "stress_level",
  "heart_rate",
  "daily_steps"
)

exploracion_variables <- tibble(
  variable = names(sleep),
  tipo = map_chr(sleep, ~paste(class(.x), collapse = "/")),
  valores_perdidos = map_int(sleep, ~sum(is.na(.x))),
  valores_unicos = map_int(sleep, ~n_distinct(.x)),
  ejemplo = map_chr(sleep, ~as.character(.x[which(!is.na(.x))[1]] %||% NA))
) %>%
  mutate(
    media = map_dbl(sleep, ~if (is.numeric(.x)) mean(.x, na.rm = TRUE) else NA_real_),
    minimo = map_dbl(sleep, ~if (is.numeric(.x)) min(.x, na.rm = TRUE) else NA_real_),
    maximo = map_dbl(sleep, ~if (is.numeric(.x)) max(.x, na.rm = TRUE) else NA_real_)
  )

primeras_observaciones <- sleep %>%
  slice_head(n = 10)

valores_perdidos <- sleep_sel %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "valores_perdidos"
  ) %>%
  arrange(desc(valores_perdidos))

rangos_cuantitativos <- sleep_sel %>%
  summarise(across(
    all_of(vars_cuantitativas),
    list(
      minimo = ~min(.x, na.rm = TRUE),
      maximo = ~max(.x, na.rm = TRUE),
      media = ~mean(.x, na.rm = TRUE),
      mediana = ~median(.x, na.rm = TRUE)
    )
  )) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable_estadistico",
    values_to = "valor"
  ) %>%
  separate(
    variable_estadistico,
    into = c("variable", "estadistico"),
    sep = "_(?=[^_]+$)"
  ) %>%
  pivot_wider(names_from = estadistico, values_from = valor)

presion_resumen <- sleep_sel %>%
  summarise(
    sistolica_min = min(systolic_bp, na.rm = TRUE),
    sistolica_max = max(systolic_bp, na.rm = TRUE),
    sistolica_media = mean(systolic_bp, na.rm = TRUE),
    diastolica_min = min(diastolic_bp, na.rm = TRUE),
    diastolica_max = max(diastolic_bp, na.rm = TRUE),
    diastolica_media = mean(diastolic_bp, na.rm = TRUE)
  )

categorias_resumen <- bind_rows(
  tabla_frecuencia(sleep_sel, gender, "Sexo"),
  tabla_frecuencia(sleep_sel, bmi_category, "Categoría de IMC"),
  tabla_frecuencia(sleep_sel, sleep_disorder_clean, "Trastorno del sueño")
)

outliers_tbl <- map_dfr(
  vars_cuantitativas,
  ~contar_outliers(sleep_sel[[.x]]) %>%
    mutate(variable = .x),
  .id = NULL
) %>%
  select(variable, limite_inferior, limite_superior, posibles_valores_extremos)

tabla_cuantitativa <- resumen_cuantitativo(sleep_sel, vars_cuantitativas)

tabla_sexo <- tabla_frecuencia(sleep_sel, gender, "Sexo")
tabla_imc <- tabla_frecuencia(sleep_sel, bmi_category, "Categoría de IMC")
tabla_trastorno <- tabla_frecuencia(sleep_sel, sleep_disorder_clean, "Trastorno del sueño")
tabla_ocupacion <- tabla_frecuencia(sleep_sel, occupation, "Ocupación") %>%
  arrange(desc(frecuencia))

trastorno_principal <- tabla_trastorno %>%
  slice_max(frecuencia, n = 1, with_ties = FALSE)

imc_principal <- tabla_imc %>%
  slice_max(frecuencia, n = 1, with_ties = FALSE)

ocupacion_principal <- tabla_ocupacion %>%
  slice_max(frecuencia, n = 1, with_ties = FALSE)

media_sueno <- mean(sleep_sel$sleep_duration, na.rm = TRUE)
mediana_sueno <- median(sleep_sel$sleep_duration, na.rm = TRUE)

cor_spearman <- cor.test(
  sleep_sel$stress_level,
  sleep_sel$quality_of_sleep,
  method = "spearman",
  exact = FALSE
)

rho_spearman <- unname(cor_spearman$estimate)
p_spearman <- cor_spearman$p.value

magnitud_spearman <- case_when(
  abs(rho_spearman) < 0.10 ~ "muy débil",
  abs(rho_spearman) < 0.30 ~ "débil",
  abs(rho_spearman) < 0.50 ~ "moderada",
  abs(rho_spearman) < 0.70 ~ "fuerte",
  TRUE ~ "muy fuerte"
)

direccion_spearman <- ifelse(
  rho_spearman < 0,
  "inversa o negativa",
  "directa o positiva"
)

decision_spearman <- ifelse(
  p_spearman < 0.05,
  "se rechaza la hipótesis nula de ausencia de asociación",
  "no se rechaza la hipótesis nula de ausencia de asociación"
)

tabla_spearman <- tibble(
  tecnica = "Correlación de Spearman",
  variable_x = "Nivel de estrés",
  variable_y = "Calidad del sueño",
  n = sum(complete.cases(sleep_sel$stress_level, sleep_sel$quality_of_sleep)),
  rho = rho_spearman,
  estadistico_s = unname(cor_spearman$statistic),
  p_value = p_spearman,
  magnitud = magnitud_spearman,
  direccion = direccion_spearman,
  decision_alpha_0_05 = decision_spearman
)

modelo_sleep <- lm(
  quality_of_sleep ~ stress_level + age + physical_activity_level,
  data = sleep_sel
)

modelo_tidy <- broom::tidy(modelo_sleep, conf.int = TRUE) %>%
  mutate(
    term = recode(
      term,
      "(Intercept)" = "Intercepto",
      "stress_level" = "Nivel de estrés",
      "age" = "Edad",
      "physical_activity_level" = "Actividad física"
    )
  )

modelo_glance <- broom::glance(modelo_sleep)

coef_estres <- modelo_tidy %>%
  filter(term == "Nivel de estrés") %>%
  pull(estimate)

p_estres <- modelo_tidy %>%
  filter(term == "Nivel de estrés") %>%
  pull(p.value)

r2_ajustado <- modelo_glance$adj.r.squared

decision_modelo <- ifelse(
  p_estres < 0.05,
  "estadísticamente significativa",
  "no estadísticamente significativa"
)

write_table(resumen_base, "01_resumen_general_base")
write_table(exploracion_variables, "02_exploracion_variables")
write_table(primeras_observaciones, "03_primeras_10_observaciones")
write_table(diccionario_variables, "04_diccionario_variables")
write_table(valores_perdidos, "05_valores_perdidos")
write_table(rangos_cuantitativos, "06_rangos_cuantitativos")
write_table(presion_resumen, "07_resumen_presion_arterial")
write_table(categorias_resumen, "08_categorias_cualitativas")
write_table(outliers_tbl, "09_outliers_riq")
write_table(tabla_cuantitativa, "10_descriptivos_cuantitativos")
write_table(tabla_sexo, "11_frecuencia_sexo")
write_table(tabla_imc, "12_frecuencia_imc")
write_table(tabla_trastorno, "13_frecuencia_trastorno_sueno")
write_table(tabla_ocupacion, "14_frecuencia_ocupacion")
write_table(tabla_spearman, "15_correlacion_spearman")
write_table(modelo_tidy, "16_coeficientes_modelo_lineal")
write_table(modelo_glance, "17_indicadores_modelo_lineal")
write_table(sleep_sel, "18_base_limpia_analisis")

markdown_tables <- c(
  "# Tablas extraídas del R Markdown",
  "",
  paste0("Fuente Rmd: `", basename(rmd_path), "`"),
  paste0("Fuente CSV: `", dataset_path, "`")
)

markdown_tables <- append_markdown_table(markdown_tables, "01. Resumen general de la base", resumen_base, 2)
markdown_tables <- append_markdown_table(markdown_tables, "02. Exploración de variables", exploracion_variables, 2)
markdown_tables <- append_markdown_table(markdown_tables, "03. Primeras 10 observaciones", primeras_observaciones, 2)
markdown_tables <- append_markdown_table(markdown_tables, "04. Diccionario de variables", diccionario_variables, 2)
markdown_tables <- append_markdown_table(markdown_tables, "05. Valores perdidos", valores_perdidos, 2)
markdown_tables <- append_markdown_table(markdown_tables, "06. Rangos cuantitativos", rangos_cuantitativos, 2)
markdown_tables <- append_markdown_table(markdown_tables, "07. Presión arterial", presion_resumen, 2)
markdown_tables <- append_markdown_table(markdown_tables, "08. Categorías cualitativas", categorias_resumen, 2)
markdown_tables <- append_markdown_table(markdown_tables, "09. Valores extremos", outliers_tbl, 2)
markdown_tables <- append_markdown_table(markdown_tables, "10. Descriptivos cuantitativos", tabla_cuantitativa, 2)
markdown_tables <- append_markdown_table(markdown_tables, "11. Sexo", tabla_sexo, 2)
markdown_tables <- append_markdown_table(markdown_tables, "12. IMC", tabla_imc, 2)
markdown_tables <- append_markdown_table(markdown_tables, "13. Trastorno del sueño", tabla_trastorno, 2)
markdown_tables <- append_markdown_table(markdown_tables, "14. Ocupación", tabla_ocupacion, 2)
markdown_tables <- append_markdown_table(markdown_tables, "15. Spearman", tabla_spearman, 4)
markdown_tables <- append_markdown_table(markdown_tables, "16. Coeficientes del modelo lineal", modelo_tidy, 4)
markdown_tables <- append_markdown_table(markdown_tables, "17. Indicadores del modelo lineal", modelo_glance, 4)
readr::write_lines(markdown_tables, file.path(table_dir, "tablas_compiladas.md"))

plot_outliers <- sleep_sel %>%
  select(all_of(vars_cuantitativas)) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "valor"
  ) %>%
  ggplot(aes(x = variable, y = valor)) +
  geom_boxplot(fill = "#A9CCE3", color = "#1B4F72", outlier.color = "#C0392B") +
  facet_wrap(~ variable, scales = "free", ncol = 3) +
  labs(
    title = "Revisión gráfica de valores extremos",
    subtitle = "Criterio visual mediante diagramas de caja por variable",
    x = NULL,
    y = "Valor observado",
    caption = "Nota. Un valor extremo no necesariamente representa un error; puede ser una observación real."
  ) +
  theme_bio() +
  theme(axis.text.x = element_blank())

plot_histograma <- ggplot(sleep_sel, aes(x = sleep_duration)) +
  geom_histogram(
    binwidth = 0.25,
    color = "white",
    fill = "#4E79A7"
  ) +
  geom_vline(
    xintercept = media_sueno,
    linetype = "dashed",
    linewidth = 1,
    color = "#E15759"
  ) +
  geom_vline(
    xintercept = mediana_sueno,
    linetype = "dotted",
    linewidth = 1,
    color = "#59A14F"
  ) +
  labs(
    title = "Distribución de la duración del sueño",
    subtitle = paste0(
      "Media = ", round(media_sueno, 2),
      " horas; mediana = ", round(mediana_sueno, 2), " horas"
    ),
    x = "Horas promedio de sueño",
    y = "Frecuencia",
    caption = "Línea roja discontinua = media; línea verde punteada = mediana."
  ) +
  theme_bio()

plot_trastorno <- tabla_trastorno %>%
  mutate(categoria = fct_reorder(categoria, frecuencia)) %>%
  ggplot(aes(x = categoria, y = frecuencia, fill = categoria)) +
  geom_col(width = 0.65) +
  geom_text(
    aes(label = paste0(frecuencia, " (", porcentaje, "%)")),
    hjust = -0.05,
    size = 3.5
  ) +
  coord_flip() +
  scale_fill_manual(values = paleta_trastorno, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Distribución de trastornos del sueño",
    subtitle = "Comparación entre ausencia de trastorno, insomnio y apnea del sueño",
    x = NULL,
    y = "Número de participantes",
    caption = "Los porcentajes se calcularon sobre el total de participantes de la base."
  ) +
  theme_bio()

plot_imc <- ggplot(sleep_sel, aes(x = bmi_category, y = quality_of_sleep, fill = bmi_category)) +
  geom_boxplot(
    width = 0.55,
    alpha = 0.85,
    outlier.shape = 21,
    outlier.fill = "white",
    outlier.color = "#C0392B"
  ) +
  geom_jitter(
    width = 0.10,
    alpha = 0.25,
    size = 1.5
  ) +
  stat_summary(
    fun = median,
    geom = "point",
    shape = 23,
    size = 3,
    fill = "white"
  ) +
  scale_fill_manual(values = paleta_imc, guide = "none") +
  labs(
    title = "Calidad del sueño según categoría de IMC",
    subtitle = "El punto blanco representa la mediana de cada grupo",
    x = "Categoría de IMC",
    y = "Calidad del sueño",
    caption = "La comparación es descriptiva; no implica causalidad ni prueba diferencias ajustadas."
  ) +
  theme_bio()

plot_estres <- ggplot(sleep_sel, aes(x = stress_level, y = quality_of_sleep)) +
  geom_jitter(
    width = 0.08,
    height = 0.08,
    alpha = 0.55,
    size = 2,
    color = "#2E86AB"
  ) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    linewidth = 1,
    color = "#C73E1D",
    fill = "#F4A261",
    alpha = 0.25
  ) +
  annotate(
    "label",
    x = min(sleep_sel$stress_level),
    y = max(sleep_sel$quality_of_sleep),
    hjust = 0,
    vjust = 1,
    label = paste0("rho de Spearman = ", round(rho_spearman, 3)),
    size = 3.5
  ) +
  labs(
    title = "A mayor estrés, menor calidad del sueño",
    subtitle = "Gráfico de dispersión con tendencia lineal exploratoria",
    x = "Nivel de estrés percibido",
    y = "Calidad del sueño",
    caption = "Los puntos tienen ligera dispersión artificial para evitar sobreposición visual."
  ) +
  theme_bio()

plot_residuos <- broom::augment(modelo_sleep) %>%
  ggplot(aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.55, color = "#2E86AB") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#C73E1D") +
  labs(
    title = "Revisión visual de residuos del modelo",
    subtitle = "Los residuos deberían distribuirse alrededor de cero",
    x = "Valores ajustados",
    y = "Residuos",
    caption = "Este gráfico permite revisar de forma exploratoria el comportamiento del error del modelo."
  ) +
  theme_bio()

save_plot(plot_outliers, "figura_01_outliers_variables_cuantitativas.png")
save_plot(plot_histograma, "figura_02_distribucion_duracion_sueno.png")
save_plot(plot_trastorno, "figura_03_frecuencia_trastornos_sueno.png")
save_plot(plot_imc, "figura_04_calidad_sueno_por_imc.png")
save_plot(plot_estres, "figura_05_estres_vs_calidad_sueno.png")
save_plot(plot_residuos, "figura_06_residuos_modelo_lineal.png")

capture.output(
  {
    cat("Estructura de sleep limpio\n")
    glimpse(sleep)
    cat("\nDimensiones\n")
    print(dim(sleep))
    cat("\nNombres de variables\n")
    print(names(sleep))
  },
  file = file.path(info_dir, "exploracion_inicial.txt")
)

capture.output(
  cor_spearman,
  file = file.path(info_dir, "salida_correlacion_spearman.txt")
)

capture.output(
  summary(modelo_sleep),
  file = file.path(info_dir, "salida_modelo_lineal.txt")
)

resumen_relevante <- c(
  "# Información relevante del análisis",
  "",
  paste0("Archivo analizado: `", basename(rmd_path), "`"),
  paste0("Base usada: `", dataset_path, "`"),
  paste0("Fecha de generación: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  "## Diseño y pregunta",
  "",
  "- Diseño: observacional, analítico y transversal.",
  "- Unidad de análisis: cada participante individual registrado en la base.",
  "- Pregunta: ¿Existe relación entre el nivel de estrés percibido y la calidad del sueño en los participantes del Sleep Health and Lifestyle Dataset?",
  "",
  "## Datos principales",
  "",
  paste0("- Registros: ", n_registros, "."),
  paste0("- Variables originales: ", n_variables, "."),
  paste0("- Duración media del sueño: ", round(media_sueno, 2), " horas."),
  paste0("- Duración mediana del sueño: ", round(mediana_sueno, 2), " horas."),
  paste0("- Calidad media del sueño: ", round(mean(sleep_sel$quality_of_sleep, na.rm = TRUE), 2), " puntos."),
  paste0("- Nivel medio de estrés: ", round(mean(sleep_sel$stress_level, na.rm = TRUE), 2), " puntos."),
  paste0("- Categoría de IMC predominante: ", imc_principal$categoria, " (", imc_principal$porcentaje, "%)."),
  paste0("- Trastorno de sueño más frecuente: ", trastorno_principal$categoria, " (", trastorno_principal$frecuencia, " participantes; ", trastorno_principal$porcentaje, "%)."),
  paste0("- Ocupación con mayor representación: ", ocupacion_principal$categoria, " (", ocupacion_principal$frecuencia, " participantes; ", ocupacion_principal$porcentaje, "%)."),
  "",
  "## Hallazgo estadístico central",
  "",
  paste0("- Spearman rho = ", round(rho_spearman, 3), "."),
  paste0("- Valor p = ", format.pval(p_spearman, digits = 3, eps = 0.001), "."),
  paste0("- Dirección: ", direccion_spearman, "."),
  paste0("- Magnitud: ", magnitud_spearman, "."),
  paste0("- Decisión con alfa 0.05: ", decision_spearman, "."),
  "",
  "## Modelo de regresión lineal múltiple",
  "",
  "- Variable dependiente: calidad del sueño.",
  "- Predictores: nivel de estrés, edad y actividad física.",
  paste0("- Coeficiente de estrés: ", round(coef_estres, 3), "."),
  paste0("- Valor p del estrés: ", format.pval(p_estres, digits = 3, eps = 0.001), "."),
  paste0("- R cuadrado ajustado: ", round(r2_ajustado, 3), "."),
  paste0("- Interpretación: la relación entre estrés y calidad del sueño es ", decision_modelo, " después de ajustar por edad y actividad física."),
  "",
  "## Conclusión interpretativa",
  "",
  "Los resultados muestran una asociación inversa entre estrés y calidad del sueño: quienes reportan mayor estrés tienden a tener menor calidad de sueño. El diseño transversal permite hablar de asociación, pero no permite afirmar causalidad.",
  "",
  "## Archivos generados",
  "",
  "- `outputs/graficas/`: seis figuras en PNG.",
  "- `outputs/tablas/`: tablas individuales en CSV, base limpia y compilado Markdown.",
  "- `outputs/informacion/`: salidas textuales de exploración, Spearman, modelo lineal y este resumen."
)

readr::write_lines(resumen_relevante, file.path(info_dir, "informacion_relevante.md"))

indice <- c(
  "# Índice de outputs",
  "",
  "## Gráficas",
  "",
  "- `graficas/figura_01_outliers_variables_cuantitativas.png`",
  "- `graficas/figura_02_distribucion_duracion_sueno.png`",
  "- `graficas/figura_03_frecuencia_trastornos_sueno.png`",
  "- `graficas/figura_04_calidad_sueno_por_imc.png`",
  "- `graficas/figura_05_estres_vs_calidad_sueno.png`",
  "- `graficas/figura_06_residuos_modelo_lineal.png`",
  "",
  "## Tablas",
  "",
  "- `tablas/01_resumen_general_base.csv`",
  "- `tablas/02_exploracion_variables.csv`",
  "- `tablas/03_primeras_10_observaciones.csv`",
  "- `tablas/04_diccionario_variables.csv`",
  "- `tablas/05_valores_perdidos.csv`",
  "- `tablas/06_rangos_cuantitativos.csv`",
  "- `tablas/07_resumen_presion_arterial.csv`",
  "- `tablas/08_categorias_cualitativas.csv`",
  "- `tablas/09_outliers_riq.csv`",
  "- `tablas/10_descriptivos_cuantitativos.csv`",
  "- `tablas/11_frecuencia_sexo.csv`",
  "- `tablas/12_frecuencia_imc.csv`",
  "- `tablas/13_frecuencia_trastorno_sueno.csv`",
  "- `tablas/14_frecuencia_ocupacion.csv`",
  "- `tablas/15_correlacion_spearman.csv`",
  "- `tablas/16_coeficientes_modelo_lineal.csv`",
  "- `tablas/17_indicadores_modelo_lineal.csv`",
  "- `tablas/18_base_limpia_analisis.csv`",
  "- `tablas/tablas_compiladas.md`",
  "",
  "## Información",
  "",
  "- `informacion/informacion_relevante.md`",
  "- `informacion/exploracion_inicial.txt`",
  "- `informacion/salida_correlacion_spearman.txt`",
  "- `informacion/salida_modelo_lineal.txt`",
  "",
  "## Reproducibilidad",
  "",
  "- `scripts/generar_outputs_sleep.R`"
)

readr::write_lines(indice, file.path(output_dir, "README.md"))

message("Outputs generados en: ", output_dir)
