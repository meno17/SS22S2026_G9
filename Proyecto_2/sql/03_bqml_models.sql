-- CaracterÃ­sticas para BigQuery ML.
-- Enero-octubre: entrenamiento. Noviembre: evaluaciÃ³n. Diciembre: datos nuevos.
-- is_eval es TRUE Ãºnicamente para noviembre; BigQuery ML no usa diciembre.

CREATE OR REPLACE TABLE `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`
PARTITION BY pickup_date
CLUSTER BY pu_location_id, do_location_id
AS
SELECT
  trip_id,
  pickup_date,
  pickup_hour,
  pickup_day_of_week,
  trip_duration_minutes,
  passenger_count,
  trip_distance,
  rate_code_id,
  pu_location_id,
  do_location_id,
  payment_type,
  fare_amount,
  tip_amount,
  high_tip,
  pickup_date >= DATE('2022-11-01') AND pickup_date < DATE('2022-12-01') AS is_eval
FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_trips_2022_optimized`
WHERE pickup_date < DATE('2022-12-01')
  AND tip_amount >= 0
  AND trip_duration_minutes BETWEEN 1 AND 180;

-- Modelo 1: regresiÃ³n; total_amount y tip_rate quedan fuera para evitar leakage.
CREATE OR REPLACE MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.tip_amount_regressor`
OPTIONS(
  model_type = 'linear_reg',
  input_label_cols = ['tip_amount'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  l2_reg = 1.0,
  learn_rate_strategy = 'constant',
  learn_rate = 0.1,
  max_iterations = 30
)
AS
SELECT
  * EXCEPT(trip_id, pickup_date, tip_amount, high_tip, is_eval)
  , tip_amount
  , is_eval
FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`;

-- Modelo 2: clasificaciÃ³n de propina alta, con pesos automÃ¡ticos para clases.
CREATE OR REPLACE MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.high_tip_classifier`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['high_tip'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  auto_class_weights = TRUE,
  l1_reg = 0.1,
  max_iterations = 30
)
AS
SELECT
  * EXCEPT(trip_id, pickup_date, tip_amount, high_tip, is_eval)
  , high_tip
  , is_eval
FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`;
