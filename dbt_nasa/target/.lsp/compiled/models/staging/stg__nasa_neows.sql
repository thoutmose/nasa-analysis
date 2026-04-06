SELECT
    id,
    neo_reference_id,
    name,
    absolute_magnitude_h,
    is_potentially_hazardous_asteroid,
    estimated_diameter__meters__estimated_diameter_min
        AS estimated_diameter_min,
    estimated_diameter__meters__estimated_diameter_max AS estimated_diameter_max
FROM
    dw_nasa_dev.dbt_nasa.base_nasa_neows_nasa_neows_response