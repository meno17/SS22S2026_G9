-- Consultas exploratorias sobre el dataset público.

-- 1) Métricas temporales para identificar demanda y recaudación.
SELECT
  DATE(pickup_datetime) AS pickup_date,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_day_of_week,
  COUNT(*) AS trip_count,
  ROUND(SUM(total_amount), 2) AS total_revenue,
  ROUND(AVG(trip_distance), 2) AS avg_distance,
  ROUND(AVG(total_amount), 2) AS avg_total_amount,
  ROUND(AVG(tip_amount), 2) AS avg_tip_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime IS NOT NULL
  AND pickup_datetime >= TIMESTAMP('2022-01-01')
  AND pickup_datetime < TIMESTAMP('2023-01-01')
GROUP BY pickup_date, pickup_day_of_week
ORDER BY pickup_date;

-- 2) Distribución horaria y por medio de pago.
SELECT
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  payment_type,
  COUNT(*) AS trip_count,
  ROUND(AVG(fare_amount), 2) AS avg_fare_amount,
  ROUND(AVG(tip_amount), 2) AS avg_tip_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime IS NOT NULL
GROUP BY pickup_hour, payment_type
ORDER BY pickup_hour, trip_count DESC;

-- 3) Rutas con mayor demanda; se excluyen identificadores nulos.
SELECT
  pickup_location_id AS pu_location_id,
  dropoff_location_id AS do_location_id,
  COUNT(*) AS trip_count,
  ROUND(AVG(trip_distance), 2) AS avg_distance,
  ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_location_id IS NOT NULL
  AND dropoff_location_id IS NOT NULL
GROUP BY pu_location_id, do_location_id
ORDER BY trip_count DESC
LIMIT 100;

-- 4) Calidad: valores atípicos y nulos por variable crítica.
SELECT
  COUNTIF(passenger_count IS NULL OR passenger_count <= 0) AS invalid_passengers,
  COUNTIF(trip_distance IS NULL OR trip_distance <= 0) AS invalid_distance,
  COUNTIF(fare_amount IS NULL OR fare_amount <= 0) AS invalid_fare,
  COUNTIF(total_amount IS NULL OR total_amount <= 0) AS invalid_total,
  COUNTIF(dropoff_datetime <= pickup_datetime) AS invalid_duration
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
