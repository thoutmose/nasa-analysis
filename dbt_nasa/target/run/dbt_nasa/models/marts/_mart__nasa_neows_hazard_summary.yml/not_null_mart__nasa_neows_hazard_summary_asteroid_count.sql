
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select asteroid_count
from dw_nasa_dev.dbt_nasa.mart__nasa_neows_hazard_summary
where asteroid_count is null



  
  
      
    ) dbt_internal_test