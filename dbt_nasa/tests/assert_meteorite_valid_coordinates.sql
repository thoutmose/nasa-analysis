-- Asserts that all meteorite records with coordinates have valid lat/lon ranges.
-- Latitude must be between -90 and 90; longitude between -180 and 180.
SELECT
    id,
    name,
    latitude,
    longitude
FROM {{ ref('mart__nasa_meteorite_landings') }}
WHERE
    (latitude IS NOT NULL AND (latitude < -90 OR latitude > 90))
    OR (longitude IS NOT NULL AND (longitude < -180 OR longitude > 180))
