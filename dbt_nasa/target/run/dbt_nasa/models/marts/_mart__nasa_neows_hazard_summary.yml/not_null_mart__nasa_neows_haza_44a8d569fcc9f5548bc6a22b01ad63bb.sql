
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_potentially_hazardous_asteroid
from dw_nasa_dev.dbt_nasa.mart__nasa_neows_hazard_summary
where is_potentially_hazardous_asteroid is null



  
  
      
    ) dbt_internal_test