
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select gst_count
from dw_nasa_dev.dbt_nasa.mart__nasa_space_weather_monthly
where gst_count is null



  
  
      
    ) dbt_internal_test