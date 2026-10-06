# Tablas extraídas del R Markdown

Fuente Rmd: `Trabajo_Final_Bioestadistica_Sleep_Health_Lifestyle_MEJORADO.Rmd`
Fuente CSV: `C:/Users/josel/OneDrive/Escritorio/RAUL/Estadistica aplicada/Bioestadistica/Proyecto Final/Sleep_health_and_lifestyle_dataset.csv`

## 01. Resumen general de la base



|indicador           | valor|
|:-------------------|-----:|
|Número de registros |   374|
|Número de variables |    13|

## 02. Exploración de variables



|variable                |tipo      | valores_perdidos| valores_unicos|ejemplo           |   media| minimo|  maximo|
|:-----------------------|:---------|----------------:|--------------:|:-----------------|-------:|------:|-------:|
|person_id               |integer   |                0|            374|1                 |  187.50|    1.0|   374.0|
|gender                  |character |                0|              2|Male              |      NA|     NA|      NA|
|age                     |integer   |                0|             31|27                |   42.18|   27.0|    59.0|
|occupation              |character |                0|             11|Software Engineer |      NA|     NA|      NA|
|sleep_duration          |numeric   |                0|             27|6.1               |    7.13|    5.8|     8.5|
|quality_of_sleep        |integer   |                0|              6|6                 |    7.31|    4.0|     9.0|
|physical_activity_level |integer   |                0|             16|42                |   59.17|   30.0|    90.0|
|stress_level            |integer   |                0|              6|6                 |    5.39|    3.0|     8.0|
|bmi_category            |character |                0|              4|Overweight        |      NA|     NA|      NA|
|blood_pressure          |character |                0|             25|126/83            |      NA|     NA|      NA|
|heart_rate              |integer   |                0|             19|77                |   70.17|   65.0|    86.0|
|daily_steps             |integer   |                0|             20|4200              | 6816.84| 3000.0| 10000.0|
|sleep_disorder          |character |                0|              3|None              |      NA|     NA|      NA|

## 03. Primeras 10 observaciones



| person_id|gender | age|occupation           | sleep_duration| quality_of_sleep| physical_activity_level| stress_level|bmi_category |blood_pressure | heart_rate| daily_steps|sleep_disorder |
|---------:|:------|---:|:--------------------|--------------:|----------------:|-----------------------:|------------:|:------------|:--------------|----------:|-----------:|:--------------|
|         1|Male   |  27|Software Engineer    |            6.1|                6|                      42|            6|Overweight   |126/83         |         77|        4200|None           |
|         2|Male   |  28|Doctor               |            6.2|                6|                      60|            8|Normal       |125/80         |         75|       10000|None           |
|         3|Male   |  28|Doctor               |            6.2|                6|                      60|            8|Normal       |125/80         |         75|       10000|None           |
|         4|Male   |  28|Sales Representative |            5.9|                4|                      30|            8|Obese        |140/90         |         85|        3000|Sleep Apnea    |
|         5|Male   |  28|Sales Representative |            5.9|                4|                      30|            8|Obese        |140/90         |         85|        3000|Sleep Apnea    |
|         6|Male   |  28|Software Engineer    |            5.9|                4|                      30|            8|Obese        |140/90         |         85|        3000|Insomnia       |
|         7|Male   |  29|Teacher              |            6.3|                6|                      40|            7|Obese        |140/90         |         82|        3500|Insomnia       |
|         8|Male   |  29|Doctor               |            7.8|                7|                      75|            6|Normal       |120/80         |         70|        8000|None           |
|         9|Male   |  29|Doctor               |            7.8|                7|                      75|            6|Normal       |120/80         |         70|        8000|None           |
|        10|Male   |  29|Doctor               |            7.8|                7|                      75|            6|Normal       |120/80         |         70|        8000|None           |

## 04. Diccionario de variables



|variable_original       |variable_en_r           |traduccion                |funcion_analitica                           |
|:-----------------------|:-----------------------|:-------------------------|:-------------------------------------------|
|Gender                  |gender                  |Sexo                      |Variable descriptiva                        |
|Age                     |age                     |Edad                      |Variable de ajuste                          |
|Sleep Duration          |sleep_duration          |Duración del sueño        |Variable descriptiva del descanso           |
|Quality of Sleep        |quality_of_sleep        |Calidad del sueño         |Variable dependiente principal              |
|Physical Activity Level |physical_activity_level |Nivel de actividad física |Variable de ajuste conductual               |
|Stress Level            |stress_level            |Nivel de estrés           |Variable independiente principal            |
|BMI Category            |bmi_category            |Categoría de IMC          |Variable descriptiva del estado nutricional |
|Blood Pressure          |blood_pressure          |Presión arterial          |Indicador fisiológico complementario        |
|Heart Rate              |heart_rate              |Frecuencia cardíaca       |Indicador fisiológico complementario        |
|Daily Steps             |daily_steps             |Pasos diarios             |Indicador de actividad cotidiana            |
|Sleep Disorder          |sleep_disorder          |Trastorno del sueño       |Variable cualitativa de salud del sueño     |
|Occupation              |occupation              |Ocupación                 |Variable sociodemográfica                   |

## 05. Valores perdidos



|variable                | valores_perdidos|
|:-----------------------|----------------:|
|gender                  |                0|
|age                     |                0|
|sleep_duration          |                0|
|quality_of_sleep        |                0|
|physical_activity_level |                0|
|stress_level            |                0|
|bmi_category            |                0|
|blood_pressure          |                0|
|systolic_bp             |                0|
|diastolic_bp            |                0|
|heart_rate              |                0|
|daily_steps             |                0|
|sleep_disorder          |                0|
|occupation              |                0|
|sleep_disorder_clean    |                0|

## 06. Rangos cuantitativos



|variable                | minimo|  maximo|   media| mediana|
|:-----------------------|------:|-------:|-------:|-------:|
|age                     |   27.0|    59.0|   42.18|    43.0|
|sleep_duration          |    5.8|     8.5|    7.13|     7.2|
|quality_of_sleep        |    4.0|     9.0|    7.31|     7.0|
|physical_activity_level |   30.0|    90.0|   59.17|    60.0|
|stress_level            |    3.0|     8.0|    5.39|     5.0|
|heart_rate              |   65.0|    86.0|   70.17|    70.0|
|daily_steps             | 3000.0| 10000.0| 6816.84|  7000.0|

## 07. Presión arterial



| sistolica_min| sistolica_max| sistolica_media| diastolica_min| diastolica_max| diastolica_media|
|-------------:|-------------:|---------------:|--------------:|--------------:|----------------:|
|           115|           142|          128.55|             75|             95|            84.65|

## 08. Categorías cualitativas



|variable            |categoria               | frecuencia| porcentaje|
|:-------------------|:-----------------------|----------:|----------:|
|Sexo                |Mujer                   |        185|      49.47|
|Sexo                |Hombre                  |        189|      50.53|
|Categoría de IMC    |Normal                  |        216|      57.75|
|Categoría de IMC    |Sobrepeso               |        148|      39.57|
|Categoría de IMC    |Obesidad                |         10|       2.67|
|Trastorno del sueño |Sin trastorno reportado |        219|      58.56|
|Trastorno del sueño |Insomnio                |         77|      20.59|
|Trastorno del sueño |Apnea del sueño         |         78|      20.86|

## 09. Valores extremos



|variable                | limite_inferior| limite_superior| posibles_valores_extremos|
|:-----------------------|---------------:|---------------:|-------------------------:|
|age                     |           13.12|           72.12|                         0|
|sleep_duration          |            4.30|            9.90|                         0|
|quality_of_sleep        |            3.00|           11.00|                         0|
|physical_activity_level |            0.00|          120.00|                         0|
|stress_level            |           -0.50|           11.50|                         0|
|heart_rate              |           62.00|           78.00|                        15|
|daily_steps             |         2000.00|        11600.00|                         0|

## 10. Descriptivos cuantitativos



|variable                |   n|   media| mediana| desviacion_estandar| minimo|  maximo|
|:-----------------------|---:|-------:|-------:|-------------------:|------:|-------:|
|age                     | 374|   42.18|    43.0|                8.67|   27.0|    59.0|
|daily_steps             | 374| 6816.84|  7000.0|             1617.92| 3000.0| 10000.0|
|heart_rate              | 374|   70.17|    70.0|                4.14|   65.0|    86.0|
|physical_activity_level | 374|   59.17|    60.0|               20.83|   30.0|    90.0|
|quality_of_sleep        | 374|    7.31|     7.0|                1.20|    4.0|     9.0|
|sleep_duration          | 374|    7.13|     7.2|                0.80|    5.8|     8.5|
|stress_level            | 374|    5.39|     5.0|                1.77|    3.0|     8.0|

## 11. Sexo



|variable |categoria | frecuencia| porcentaje|
|:--------|:---------|----------:|----------:|
|Sexo     |Mujer     |        185|      49.47|
|Sexo     |Hombre    |        189|      50.53|

## 12. IMC



|variable         |categoria | frecuencia| porcentaje|
|:----------------|:---------|----------:|----------:|
|Categoría de IMC |Normal    |        216|      57.75|
|Categoría de IMC |Sobrepeso |        148|      39.57|
|Categoría de IMC |Obesidad  |         10|       2.67|

## 13. Trastorno del sueño



|variable            |categoria               | frecuencia| porcentaje|
|:-------------------|:-----------------------|----------:|----------:|
|Trastorno del sueño |Sin trastorno reportado |        219|      58.56|
|Trastorno del sueño |Insomnio                |         77|      20.59|
|Trastorno del sueño |Apnea del sueño         |         78|      20.86|

## 14. Ocupación



|variable  |categoria            | frecuencia| porcentaje|
|:---------|:--------------------|----------:|----------:|
|Ocupación |Nurse                |         73|      19.52|
|Ocupación |Doctor               |         71|      18.98|
|Ocupación |Engineer             |         63|      16.84|
|Ocupación |Lawyer               |         47|      12.57|
|Ocupación |Teacher              |         40|      10.70|
|Ocupación |Accountant           |         37|       9.89|
|Ocupación |Salesperson          |         32|       8.56|
|Ocupación |Scientist            |          4|       1.07|
|Ocupación |Software Engineer    |          4|       1.07|
|Ocupación |Sales Representative |          2|       0.53|
|Ocupación |Manager              |          1|       0.27|

## 15. Spearman



|tecnica                 |variable_x      |variable_y        |   n|     rho| estadistico_s| p_value|magnitud   |direccion          |decision_alpha_0_05                                    |
|:-----------------------|:---------------|:-----------------|---:|-------:|-------------:|-------:|:----------|:------------------|:------------------------------------------------------|
|Correlación de Spearman |Nivel de estrés |Calidad del sueño | 374| -0.9081|      16636896|       0|muy fuerte |inversa o negativa |se rechaza la hipótesis nula de ausencia de asociación |

## 16. Coeficientes del modelo lineal



|term             | estimate| std.error| statistic| p.value| conf.low| conf.high|
|:----------------|--------:|---------:|---------:|-------:|--------:|---------:|
|Intercepto       |   9.4301|    0.1916|   49.2082|  0.0000|   9.0533|    9.8069|
|Nivel de estrés  |  -0.5786|    0.0155|  -37.3315|  0.0000|  -0.6091|   -0.5482|
|Edad             |   0.0117|    0.0032|    3.6354|  0.0003|   0.0054|    0.0180|
|Actividad física |   0.0085|    0.0012|    7.0108|  0.0000|   0.0061|    0.0109|

## 17. Indicadores del modelo lineal



| r.squared| adj.r.squared| sigma| statistic| p.value| df|    logLik|      AIC|      BIC| deviance| df.residual| nobs|
|---------:|-------------:|-----:|---------:|-------:|--:|---------:|--------:|--------:|--------:|-----------:|----:|
|    0.8398|        0.8385| 0.481|   646.644|       0|  3| -254.9357| 519.8714| 539.4927|  85.5988|         370|  374|
