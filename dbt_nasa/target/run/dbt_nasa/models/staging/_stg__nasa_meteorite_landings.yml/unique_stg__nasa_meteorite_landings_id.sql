
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.stg__nasa_meteorite_landings
where id is not null
group by id
having count(*) > 1



  
  
      
    ) dbt_internal_test