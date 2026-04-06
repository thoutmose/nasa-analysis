-- Asserts that all solar flare class_category values are valid NOAA letter classes.
-- Valid classes: X (extreme), M (major), C (common), B (below average), A (minimal).
SELECT
    flr_id,
    class_type,
    class_category
FROM {{ ref('mart__nasa_donki_solar_flare') }}
WHERE class_category NOT IN ('X', 'M', 'C', 'B', 'A')
