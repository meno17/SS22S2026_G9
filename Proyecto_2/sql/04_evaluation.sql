-- EvaluaciÃ³n sobre el split de noviembre (is_eval = TRUE).

SELECT 'tip_amount_regressor' AS model_name, *
FROM ML.EVALUATE(
  MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.tip_amount_regressor`,
  (
    SELECT
      * EXCEPT(trip_id, pickup_date, tip_amount, high_tip),
      tip_amount
    FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`
    WHERE is_eval
  )
);

SELECT 'high_tip_classifier' AS model_name, *
FROM ML.EVALUATE(
  MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.high_tip_classifier`,
  (
    SELECT
      * EXCEPT(trip_id, pickup_date, tip_amount, high_tip),
      high_tip
    FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`
    WHERE is_eval
  )
);

-- ROC-AUC y puntos de operaciÃ³n del clasificador.
SELECT *
FROM ML.ROC_CURVE(
  MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.high_tip_classifier`,
  (
    SELECT
      * EXCEPT(trip_id, pickup_date, tip_amount, high_tip),
      high_tip
    FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`
    WHERE is_eval
  )
)
ORDER BY threshold;

-- Matriz de confusiÃ³n con el umbral por defecto y umbrales alternativos.
SELECT *
FROM ML.CONFUSION_MATRIX(
  MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.high_tip_classifier`,
  (
    SELECT
      * EXCEPT(trip_id, pickup_date, tip_amount, high_tip),
      high_tip
    FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`
    WHERE is_eval
  ),
  STRUCT(0.5 AS threshold)
);

SELECT *
FROM ML.CONFUSION_MATRIX(
  MODEL `ss2-proyecto2-g9-2026.proyecto2_taxi.high_tip_classifier`,
  (
    SELECT
      * EXCEPT(trip_id, pickup_date, tip_amount, high_tip),
      high_tip
    FROM `ss2-proyecto2-g9-2026.proyecto2_taxi.taxi_ml_features`
    WHERE is_eval
  ),
  STRUCT(0.7 AS threshold)
);

