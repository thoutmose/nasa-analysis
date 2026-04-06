
  create or replace   view dw_nasa_dev.dbt_nasa.stg__nasa_donki_solar_flare
  
  
  
  
  as (
    SELECT
    flr_id,
    begin_time,
    peak_time,
    end_time,
    class_type,
    source_location
FROM
    dw_nasa_dev.dbt_nasa.base_nasa_donki_solar_flare_nasa_donki_response
  );

