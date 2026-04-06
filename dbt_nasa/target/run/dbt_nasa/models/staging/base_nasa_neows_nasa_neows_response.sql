
  create or replace   view dw_nasa_dev.dbt_nasa.base_nasa_neows_nasa_neows_response
  
  
  
  
  as (
    with source as (
        select * from dw_nasa_dev.nasa_neows.nasa_neows_response
  ),
  renamed as (
      select
          id,
        neo_reference_id,
        name,
        nasa_jpl_url,
        absolute_magnitude_h,
        is_potentially_hazardous_asteroid,
        is_sentry_object,
        estimated_diameter__feet__estimated_diameter_min,
        estimated_diameter__feet__estimated_diameter_max,
        estimated_diameter__miles__estimated_diameter_min,
        estimated_diameter__miles__estimated_diameter_max,
        estimated_diameter__meters__estimated_diameter_min,
        estimated_diameter__meters__estimated_diameter_max,
        estimated_diameter__kilometers__estimated_diameter_min,
        estimated_diameter__kilometers__estimated_diameter_max,
        links__self,
        _dlt_load_id,
        _dlt_id,
        sentry_data

      from source
  )
  select * from renamed
  );

