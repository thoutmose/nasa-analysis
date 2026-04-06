
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select flr_id
from dw_nasa_dev.dbt_nasa.stg__nasa_donki_solar_flare
where flr_id is null



  
  
      
    ) dbt_internal_test