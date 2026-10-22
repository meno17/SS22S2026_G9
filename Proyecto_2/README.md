# Proyecto 2 Â· AnÃ¡lisis masivo de NYC Taxi Trips 2022

**Universidad de San Carlos de Guatemala Â· Seminario de Sistemas 2 Â· Grupo 9**

Este proyecto implementa el anÃ¡lisis exploratorio y predictivo solicitado sobre
`bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` usando Google
BigQuery y BigQuery ML.

## Integrantes

- Walter Daniel JimÃ©nez Hernandez Â· 201901108
- Esteban Palacios Kestler Â· 201020697
- JosÃ© Ricardo Menocal Kong Â· 202000886

## Estructura

| Archivo | PropÃ³sito |
| --- | --- |
| `sql/00_setup.sql` | Variables, validaciÃ³n del dataset pÃºblico y creaciÃ³n del esquema |
| `sql/01_exploration.sql` | Conteos, calidad, mÃ©tricas temporales, categÃ³ricas y geogrÃ¡ficas |
| `sql/02_optimized_table.sql` | Tabla derivada particionada y clusterizada |
| `sql/03_bqml_models.sql` | Tabla de caracterÃ­sticas y entrenamiento de dos modelos |
| `sql/04_evaluation.sql` | MÃ©tricas, comparaciÃ³n, ROC y matriz de confusiÃ³n |
| `sql/05_predictions.sql` | Predicciones sobre diciembre, reservado como perÃ­odo nuevo |
| `docs/dashboard.md` | EspecificaciÃ³n de visualizaciones para Sheets o Looker Studio |

## ConfiguraciÃ³n

1. Crear un proyecto de Google Cloud con BigQuery habilitado y facturaciÃ³n
   configurada.
2. En BigQuery, sustituir `ss2-proyecto2-g9-2026` en los scripts por el ID del
   proyecto propio. El dataset pÃºblico no se copia: se consulta directamente.
3. Ejecutar los scripts en orden. `00_setup.sql` crea
   `ss2-proyecto2-g9-2026.proyecto2_taxi`; los demÃ¡s scripts lo reutilizan.
4. Activar **Query settings â†’ Maximum bytes billed** antes de ejecutar una
   consulta exploratoria grande y guardar para la entrega la informaciÃ³n de
   bytes procesados de las consultas estÃ¡ndar y optimizadas.

El flujo estÃ¡ diseÃ±ado para trabajar con mÃ¡s de un millÃ³n de registros. Las
consultas exploratorias limitan la salida, pero no sustituyen el filtro de
particiÃ³n de las tablas derivadas.

## Decisiones analÃ­ticas

- La tabla derivada se particiona por `pickup_date` y se clusteriza por
  `pu_location_id`, `do_location_id` y `payment_type`, que son columnas usadas
  en filtros y agrupaciones.
- El entrenamiento usa enero-noviembre de 2022 y diciembre queda reservado
  para predicciÃ³n. Esto evita que registros futuros contaminen el entrenamiento.
- El modelo de regresiÃ³n predice `tip_amount` usando solamente variables
  disponibles al inicio o durante el viaje, no `total_amount`, `tip_amount` ni
  ninguna variable calculada a partir del objetivo.
- El modelo de clasificaciÃ³n predice `high_tip`, definido como propina de al
  menos 20% de la tarifa. La etiqueta se crea antes del split, pero no se usa
  como variable de entrada.
- `is_eval` es un split personalizado de BigQuery ML: `FALSE` para
  enero-noviembre y `TRUE` para una muestra de evaluaciÃ³n dentro de noviembre.
  Diciembre no participa en entrenamiento ni evaluaciÃ³n; se usa Ãºnicamente como
  datos nuevos en `05_predictions.sql`.

## Modelos

1. `tip_amount_regressor`: regresiÃ³n lineal con `l2_reg`,
   `learn_rate_strategy='constant'`, `learn_rate=0.1` y
   `max_iterations=30`. MÃ©tricas: `MAE`, `RMSE`, `R2_SCORE` y `MAPE`.
2. `high_tip_classifier`: regresiÃ³n logÃ­stica con `auto_class_weights=TRUE`,
   `l1_reg=0.1` y `max_iterations=30`. MÃ©tricas: `accuracy`, `precision`,
   `recall`, `f1_score`, `log_loss` y ROC-AUC.

La consulta de evaluaciÃ³n devuelve los resultados de ambos modelos junto con
la curva ROC y una matriz de confusiÃ³n en varios umbrales. La selecciÃ³n final
debe justificarse con esas mÃ©tricas y no Ãºnicamente con la exactitud.

## Evidencias y tablero

Para cumplir la entrega, conservar capturas o enlaces que demuestren:

- conteo y esquema del dataset pÃºblico;
- bytes procesados de una consulta estÃ¡ndar frente a la misma consulta sobre la
  tabla particionada y clusterizada;
- configuraciÃ³n de particiÃ³n/clustering de la tabla derivada;
- entrenamiento y evaluaciÃ³n de ambos modelos;
- predicciones de diciembre;
- tablero con al menos tres visualizaciones exploratorias y dos visualizaciones
  de predicciones.

La especificaciÃ³n de campos, filtros y grÃ¡ficos estÃ¡ en
[`docs/dashboard.md`](docs/dashboard.md).

## LimitaciÃ³n reproducible

Los scripts no incluyen credenciales ni un `project_id` real. BigQuery requiere
que cada integrante ejecute las consultas con su propia cuenta y permisos.
Esto evita publicar secretos en el repositorio y permite reproducir el trabajo
en cualquier proyecto autorizado.

