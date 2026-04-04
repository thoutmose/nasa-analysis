with source as (
        select * from {{ source('nasa_meteorite_landings', 'meteorite_landings') }}
  ),
  renamed as (
      select
          {{ adapter.quote("name") }},
        {{ adapter.quote("id") }},
        {{ adapter.quote("nametype") }},
        {{ adapter.quote("recclass") }},
        {{ adapter.quote("mass") }},
        {{ adapter.quote("fall") }},
        {{ adapter.quote("year") }},
        {{ adapter.quote("reclat") }},
        {{ adapter.quote("reclong") }},
        {{ adapter.quote("geolocation") }},
        {{ adapter.quote("_dlt_load_id") }},
        {{ adapter.quote("_dlt_id") }}

      from source
  )
  select * from renamed
    