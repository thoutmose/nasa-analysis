-- Solar flare count grouped by year, month, and NOAA class category.
-- Useful for time-series visualizations of flare intensity trends.
SELECT
    event_year,
    event_month,
    class_category,
    COUNT(*)                                AS flare_count
FROM {{ ref('mart__nasa_donki_solar_flare') }}
GROUP BY event_year, event_month, class_category
