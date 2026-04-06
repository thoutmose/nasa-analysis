with source as (
        select * from dw_nasa_dev.nasa_meteorite_landings.meteorite_landings
  ),
  renamed as (
      select
          name,
        id,
        nametype,
        recclass,
        mass,
        fall,
        year,
        reclat,
        reclong,
        geolocation,
        _dlt_load_id,
        _dlt_id

      from source
  )
  select * from renamed