
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    flr_id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_donki_solar_flare
where flr_id is not null
group by flr_id
having count(*) > 1



  
  
      
    ) dbt_internal_test