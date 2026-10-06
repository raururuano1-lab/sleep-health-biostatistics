# Análisis bioestadístico de salud y estilo de vida del sueño

Proyecto académico realizado durante la **Maestría en Estadística Aplicada** de la
Universidad de San Carlos de Guatemala, dentro del curso de Bioestadística.

> El trabajo original fue desarrollado en equipo. Esta versión de portafolio fue
> preparada por Raúl Antonio Ruano Katz y omite registros académicos y otros datos
> personales.

## Objetivo

Estudiar la relación entre calidad del sueño, estrés, actividad física, edad,
ocupación, composición corporal y trastornos del sueño mediante técnicas
descriptivas e inferenciales.

## Metodología

- validación y limpieza de la base;
- análisis de valores faltantes y atípicos;
- estadística descriptiva y visualización;
- correlación de Spearman;
- modelo lineal múltiple para calidad del sueño;
- diagnóstico de residuos y comunicación de resultados.

## Resultado destacado

El modelo lineal explica aproximadamente 84% de la variabilidad observada en la
calidad del sueño (`R² = 0.840`). Manteniendo las demás variables constantes, un
punto adicional de estrés se asocia con una reducción estimada de 0.579 puntos en
la calidad del sueño. El resultado describe asociación y no causalidad.

## Estructura

```text
├── analysis.Rmd
├── data/
│   └── sleep_health_and_lifestyle.csv
├── src/
│   └── generate_outputs.R
└── outputs/
    ├── figures/
    ├── tables/
    └── report/
```

## Reproducción

Requiere R 4.x y los paquetes enumerados en `requirements.R`:

```r
source("src/generate_outputs.R", encoding = "UTF-8")
rmarkdown::render("analysis.Rmd", encoding = "UTF-8")
```

## Datos y alcance

Se utiliza una base secundaria de salud y estilo de vida con fines educativos.
Los registros no identifican directamente a personas. Los resultados no son una
recomendación clínica ni permiten establecer relaciones causales.

