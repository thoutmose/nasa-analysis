-- Aggregate asteroid statistics split by hazard flag.
-- Useful for pie-chart and stat-panel visualizations comparing
-- hazardous vs. non-hazardous near-Earth objects.
SELECT
    is_potentially_hazardous_asteroid,
    COUNT(*)                                AS asteroid_count,
    ROUND(AVG(estimated_diameter_min), 2)  AS avg_diameter_min_m,
    ROUND(AVG(estimated_diameter_max), 2)  AS avg_diameter_max_m,
    ROUND(MIN(estimated_diameter_min), 2)  AS min_diameter_m,
    ROUND(MAX(estimated_diameter_max), 2)  AS max_diameter_m,
    ROUND(AVG(absolute_magnitude_h), 2)    AS avg_absolute_magnitude_h
FROM dw_nasa_dev.dbt_nasa.mart__nasa_neows
GROUP BY is_potentially_hazardous_asteroid