
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select gst_id
from dw_nasa_dev.dbt_nasa.mart__nasa_donki_gst
where gst_id is null



  
  
      
    ) dbt_internal_test