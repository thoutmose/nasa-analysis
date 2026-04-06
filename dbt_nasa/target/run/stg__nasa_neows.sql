
  create view "dw_nasa_dev"."nasa_dbt"."stg__nasa_neows__dbt_tmp"
    
    
  as (
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
    "dw_nasa_dev"."nasa_db"."nasa_neows_response"
  );