
  
    

create or replace transient table dw_nasa_dev.dbt_nasa.mart__nasa_neows
    
    
    
    as (SELECT
    *
FROM dw_nasa_dev.dbt_nasa.stg__nasa_neows
    )
;


  