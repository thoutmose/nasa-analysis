SELECT
    id,
    name,
    nametype,
    recclass,
    mass,
    fall,
    year,
    reclat,
    reclong,
    geolocation
FROM
    {{ source('nasa_meteorite_landings', 'meteorite_landings') }}
