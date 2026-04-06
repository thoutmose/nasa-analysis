
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select class_category
from dw_nasa_dev.dbt_nasa.mart__nasa_solar_flare_class_summary
where class_category is null



  
  
      
    ) dbt_internal_test