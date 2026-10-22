-- Tabla derivada: se limpian registros imposibles y se agregan caracterÃ­sticas.
-- El filtro de fecha en las consultas posteriores permite podar particiones.

CREATE OR REPLACE TABLE `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_trips_2022_optimized`
PARTITION BY pickup_date
CLUSTER BY pu_location_id, do_location_id, payment_type
OPTIONS(require_partition_filter = TRUE)
AS
SELECT
  FARM_FINGERPRINT(CONCAT(
    CAST(vendor_id AS STRING), '|',
    CAST(pickup_datetime AS STRING), '|',
    CAST(dropoff_datetime AS STRING), '|',
    CAST(pickup_location_id AS STRING), '|',
    CAST(dropoff_location_id AS STRING)
  )) AS trip_id,
  DATE(pickup_datetime) AS pickup_date,
  pickup_datetime,
  dropoff_datetime,
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_day_of_week,
  TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) AS trip_duration_minutes,
  CAST(passenger_count AS INT64) AS passenger_count,
  CAST(trip_distance AS FLOAT64) AS trip_distance,
  SAFE_CAST(rate_code AS FLOAT64) AS rate_code_id,
  CAST(pickup_location_id AS INT64) AS pu_location_id,
  CAST(dropoff_location_id AS INT64) AS do_location_id,
  CAST(payment_type AS INT64) AS payment_type,
  CAST(fare_amount AS FLOAT64) AS fare_amount,
  CAST(tip_amount AS FLOAT64) AS tip_amount,
  CAST(total_amount AS FLOAT64) AS total_amount,
  SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) AS tip_rate,
  IF(SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0)) >= 0.20, TRUE, FALSE) AS high_tip
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= TIMESTAMP('2022-01-01')
  AND pickup_datetime < TIMESTAMP('2023-01-01')
  AND dropoff_datetime > pickup_datetime
  AND passenger_count > 0
  AND trip_distance > 0
  AND fare_amount > 0
  AND total_amount > 0
  AND pickup_location_id IS NOT NULL
  AND dropoff_location_id IS NOT NULL;

-- Comparar esta consulta con una consulta equivalente sobre la tabla pÃºblica.
-- ESTÃNDAR: no tiene poda por una tabla propia particionada/clusterizada.
SELECT
  DATE(pickup_datetime) AS pickup_date,
  pickup_location_id AS pu_location_id,
  dropoff_location_id AS do_location_id,
  COUNT(*) AS trip_count,
  ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime >= TIMESTAMP('2022-01-01')
  AND pickup_datetime < TIMESTAMP('2023-01-01')
  AND pickup_location_id IN (1, 132, 138)
GROUP BY pickup_date, pu_location_id, do_location_id
ORDER BY pickup_date, trip_count DESC;

-- OPTIMIZADA: filtra la particiÃ³n y aprovecha el clustering por ubicaciÃ³n.
SELECT
  pickup_date,
  pu_location_id,
  do_location_id,
  COUNT(*) AS trip_count,
  ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_trips_2022_optimized`
WHERE pickup_date BETWEEN DATE('2022-01-01') AND DATE('2022-12-31')
  AND pu_location_id IN (1, 132, 138)
GROUP BY pickup_date, pu_location_id, do_location_id
ORDER BY pickup_date, trip_count DESC;
