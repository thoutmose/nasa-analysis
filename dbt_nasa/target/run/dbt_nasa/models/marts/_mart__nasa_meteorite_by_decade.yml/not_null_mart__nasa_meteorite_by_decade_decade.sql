
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select decade
from dw_nasa_dev.dbt_nasa.mart__nasa_meteorite_by_decade
where decade is null



  
  
      
    ) dbt_internal_test