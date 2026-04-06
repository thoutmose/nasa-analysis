
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select name
from dw_nasa_dev.dbt_nasa.stg__nasa_meteorite_landings
where name is null



  
  
      
    ) dbt_internal_test