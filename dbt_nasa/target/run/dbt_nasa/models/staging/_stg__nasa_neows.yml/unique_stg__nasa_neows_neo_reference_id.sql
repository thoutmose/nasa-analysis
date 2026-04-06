
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    neo_reference_id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.stg__nasa_neows
where neo_reference_id is not null
group by neo_reference_id
having count(*) > 1



  
  
      
    ) dbt_internal_test