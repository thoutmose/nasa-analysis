-- Monthly count of geomagnetic storm events and solar flare events.
-- Enables combined space-weather trend dashboards across both DONKI datasets.
WITH gst_monthly AS (
    SELECT
        event_year,
        event_month,
        COUNT(*)                            AS gst_count
    FROM {{ ref('mart__nasa_donki_gst') }}
    GROUP BY event_year, event_month
),
flare_monthly AS (
    SELECT
        event_year,
        event_month,
        COUNT(*)                            AS flare_count
    FROM {{ ref('mart__nasa_donki_solar_flare') }}
    GROUP BY event_year, event_month
),
all_months AS (
    SELECT event_year, event_month FROM gst_monthly
    UNION
    SELECT event_year, event_month FROM flare_monthly
)
SELECT
    m.event_year,
    m.event_month,
    COALESCE(g.gst_count, 0)               AS gst_count,
    COALESCE(f.flare_count, 0)             AS flare_count
FROM all_months m
LEFT JOIN gst_monthly g
    ON  m.event_year  = g.event_year
    AND m.event_month = g.event_month
LEFT JOIN flare_monthly f
    ON  m.event_year  = f.event_year
    AND m.event_month = f.event_month
