
  create or replace   view dw_nasa_dev.dbt_nasa.stg__nasa_donki_gst
  
  
  
  
  as (
    SELECT
    gst_id,
    start_time
FROM
    dw_nasa_dev.dbt_nasa.base_nasa_donki_gst_nasa_donki_gst_response
  );

