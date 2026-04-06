
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    is_potentially_hazardous_asteroid as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_neows_hazard_summary
where is_potentially_hazardous_asteroid is not null
group by is_potentially_hazardous_asteroid
having count(*) > 1



  
  
      
    ) dbt_internal_test