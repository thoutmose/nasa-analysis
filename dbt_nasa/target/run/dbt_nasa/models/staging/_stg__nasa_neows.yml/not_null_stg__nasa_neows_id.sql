
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select id
from dw_nasa_dev.dbt_nasa.stg__nasa_neows
where id is null



  
  
      
    ) dbt_internal_test