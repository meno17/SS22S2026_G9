-- Proyecto 2: validaciÃ³n inicial y preparaciÃ³n del dataset propio.
-- Sustituir ss2-proyecto2-g9-2026 por el ID del proyecto de Google Cloud.

DECLARE project_id STRING DEFAULT 'ss2-proyecto2-g9-2026';

CREATE SCHEMA IF NOT EXISTS `ss2-proyecto2-g9-2026.proyecto2_taxi`
OPTIONS(location = 'US');

-- Evidencia mÃ­nima del dataset pÃºblico y de su estructura.
SELECT
  COUNT(*) AS total_rows,
  MIN(pickup_datetime) AS first_pickup,
  MAX(pickup_datetime) AS last_pickup,
  COUNTIF(pickup_datetime IS NULL) AS null_pickup_datetime,
  COUNTIF(dropoff_datetime IS NULL) AS null_dropoff_datetime,
  COUNTIF(trip_distance < 0) AS negative_distance,
  COUNTIF(total_amount < 0) AS negative_total_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

SELECT
  column_name,
  data_type,
  is_nullable
FROM `bigquery-public-data.new_york_taxi_trips.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'tlc_yellow_trips_2022'
ORDER BY ordinal_position;
