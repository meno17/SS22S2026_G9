# Especificación del tablero

Crear una fuente de datos de BigQuery por cada consulta guardada o exportar los
resultados a Google Sheets. Las siguientes visualizaciones cubren el alcance
mínimo del proyecto.

## Visualizaciones exploratorias

1. **Viajes y recaudación por día**: serie temporal con `pickup_date`,
   `trip_count` y `total_revenue` de `01_exploration.sql`.
2. **Rutas con mayor demanda**: tabla o barras con
   `pu_location_id`, `do_location_id`, `trip_count` y `avg_total_amount`.
3. **Medios de pago**: barras apiladas por `payment_type`, con cantidad de
   viajes, tarifa media y propina media.

## Visualizaciones predictivas

4. **Propina real frente a estimada**: serie o dispersión de
   `tip_amount` y `predicted_tip_amount` de `05_predictions.sql`.
5. **Probabilidad de propina alta**: barras por fecha o zona usando
   `predicted_high_tip_probs` y `predicted_high_tip`.

Agregar filtros por fecha, zona de origen, zona de destino y medio de pago.
Cada gráfico debe incluir título, unidades, período analizado y una nota breve
con el hallazgo observado.
