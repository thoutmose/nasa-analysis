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
    {{ ref('base_nasa_meteorite_landings_meteorite_landings') }}
