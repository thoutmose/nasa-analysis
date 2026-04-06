
  create or replace   view dw_nasa_dev.dbt_nasa.base_nasa_donki_solar_flare_nasa_donki_response
  
  
  
  
  as (
    with source as (
    select * from dw_nasa_dev.nasa_donki_solar_flare.nasa_donki_response
),
renamed as (
    select
        flr_id,
        begin_time,
        peak_time,
        end_time,
        class_type,
        source_location,
        active_region_num,
        _dlt_load_id,
        _dlt_id

    from source
)
select * from renamed
  );

