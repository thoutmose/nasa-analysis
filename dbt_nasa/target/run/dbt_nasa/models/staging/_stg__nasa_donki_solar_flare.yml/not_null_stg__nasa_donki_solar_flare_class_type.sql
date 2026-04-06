
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select class_type
from dw_nasa_dev.dbt_nasa.stg__nasa_donki_solar_flare
where class_type is null



  
  
      
    ) dbt_internal_test