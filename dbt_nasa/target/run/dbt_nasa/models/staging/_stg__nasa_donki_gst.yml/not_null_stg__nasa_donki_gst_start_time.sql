
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select start_time
from dw_nasa_dev.dbt_nasa.stg__nasa_donki_gst
where start_time is null



  
  
      
    ) dbt_internal_test