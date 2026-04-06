-- Asserts that every asteroid has estimated_diameter_min < estimated_diameter_max.
-- A violation indicates corrupted or inverted diameter data from the NASA NeoWs API.
SELECT
    id,
    name,
    estimated_diameter_min,
    estimated_diameter_max
FROM dw_nasa_dev.dbt_nasa.mart__nasa_neows
WHERE estimated_diameter_min >= estimated_diameter_max