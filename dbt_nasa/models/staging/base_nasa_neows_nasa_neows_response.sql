with source as (
        select * from {{ source('nasa_neows', 'nasa_neows_response') }}
  ),
  renamed as (
      select
          {{ adapter.quote("id") }},
        {{ adapter.quote("neo_reference_id") }},
        {{ adapter.quote("name") }},
        {{ adapter.quote("nasa_jpl_url") }},
        {{ adapter.quote("absolute_magnitude_h") }},
        {{ adapter.quote("is_potentially_hazardous_asteroid") }},
        {{ adapter.quote("is_sentry_object") }},
        {{ adapter.quote("estimated_diameter__feet__estimated_diameter_min") }},
        {{ adapter.quote("estimated_diameter__feet__estimated_diameter_max") }},
        {{ adapter.quote("estimated_diameter__miles__estimated_diameter_min") }},
        {{ adapter.quote("estimated_diameter__miles__estimated_diameter_max") }},
        {{ adapter.quote("estimated_diameter__meters__estimated_diameter_min") }},
        {{ adapter.quote("estimated_diameter__meters__estimated_diameter_max") }},
        {{ adapter.quote("estimated_diameter__kilometers__estimated_diameter_min") }},
        {{ adapter.quote("estimated_diameter__kilometers__estimated_diameter_max") }},
        {{ adapter.quote("links__self") }},
        {{ adapter.quote("_dlt_load_id") }},
        {{ adapter.quote("_dlt_id") }},
        {{ adapter.quote("sentry_data") }}

      from source
  )
  select * from renamed
    