
  create or replace   view dw_nasa_dev.dbt_nasa.stg__nasa_meteorite_landings
  
  
  
  
  as (
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
    dw_nasa_dev.dbt_nasa.base_nasa_meteorite_landings_meteorite_landings
  );

