
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    decade as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_meteorite_by_decade
where decade is not null
group by decade
having count(*) > 1



  
  
      
    ) dbt_internal_test