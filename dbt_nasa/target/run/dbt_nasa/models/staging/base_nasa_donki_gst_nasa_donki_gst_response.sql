
  create or replace   view dw_nasa_dev.dbt_nasa.base_nasa_donki_gst_nasa_donki_gst_response
  
  
  
  
  as (
    with source as (
    select * from dw_nasa_dev.nasa_donki_gst.nasa_donki_gst_response
),
renamed as (
    select
        gst_id,
        start_time,
        _dlt_load_id,
        _dlt_id

    from source
)
select * from renamed
  );

