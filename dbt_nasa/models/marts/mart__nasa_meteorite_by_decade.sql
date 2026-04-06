-- Meteorite landing counts and mass statistics aggregated by decade.
-- Useful for historical bar-chart / timeline visualizations.
SELECT
    FLOOR(landing_year / 10) * 10           AS decade,
    COUNT(*)                                AS landing_count,
    ROUND(AVG(mass_grams), 2)               AS avg_mass_grams,
    ROUND(SUM(mass_grams), 2)               AS total_mass_grams,
    COUNT(DISTINCT recclass)                AS distinct_class_count
FROM {{ ref('mart__nasa_meteorite_landings') }}
WHERE landing_year IS NOT NULL
GROUP BY decade
