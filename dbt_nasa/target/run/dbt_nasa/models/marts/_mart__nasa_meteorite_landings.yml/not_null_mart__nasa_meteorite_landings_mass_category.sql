
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select mass_category
from dw_nasa_dev.dbt_nasa.mart__nasa_meteorite_landings
where mass_category is null



  
  
      
    ) dbt_internal_test