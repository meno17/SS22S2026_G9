-- Predicciones sobre diciembre de 2022, que no fue usado para entrenar ni evaluar.
CREATE OR REPLACE TABLE `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_predictions_2022_12`
PARTITION BY pickup_date
CLUSTER BY pu_location_id, do_location_id
AS
WITH new_records AS (
  SELECT
    *
  FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_trips_2022_optimized`
  WHERE pickup_date >= DATE('2022-12-01')
    AND pickup_date < DATE('2023-01-01')
    AND trip_duration_minutes BETWEEN 1 AND 180
),
reg_predictions AS (
  SELECT
    trip_id,
    predicted_tip_amount
  FROM ML.PREDICT(
    MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.tip_amount_regressor`,
    (SELECT * EXCEPT(trip_id, pickup_date, tip_amount, high_tip, tip_rate, total_amount)
     FROM new_records)
  )
),
class_predictions AS (
  SELECT
    trip_id,
    predicted_high_tip,
    predicted_high_tip_probs
  FROM ML.PREDICT(
    MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.high_tip_classifier`,
    (SELECT * EXCEPT(trip_id, pickup_date, tip_amount, high_tip, tip_rate, total_amount)
     FROM new_records)
  )
)
SELECT
  r.trip_id,
  r.pickup_date,
  r.pickup_datetime,
  r.pu_location_id,
  r.do_location_id,
  r.payment_type,
  r.trip_distance,
  r.fare_amount,
  r.tip_amount,
  r.high_tip AS actual_high_tip,
  reg.predicted_tip_amount,
  cls.predicted_high_tip,
  cls.predicted_high_tip_probs
FROM new_records AS r
JOIN reg_predictions AS reg USING (trip_id)
JOIN class_predictions AS cls USING (trip_id);

SELECT
  pickup_date,
  COUNT(*) AS predicted_trips,
  ROUND(AVG(predicted_tip_amount), 2) AS avg_predicted_tip,
  ROUND(AVG(CAST(actual_high_tip AS INT64)), 4) AS actual_high_tip_rate,
  ROUND(AVG(CAST(predicted_high_tip AS INT64)), 4) AS predicted_high_tip_rate
FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_predictions_2022_12`
GROUP BY pickup_date
ORDER BY pickup_date;

