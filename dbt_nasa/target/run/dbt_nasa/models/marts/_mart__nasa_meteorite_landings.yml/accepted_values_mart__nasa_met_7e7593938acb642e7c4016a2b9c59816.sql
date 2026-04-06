
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        mass_category as value_field,
        count(*) as n_records

    from dw_nasa_dev.dbt_nasa.mart__nasa_meteorite_landings
    group by mass_category

)

select *
from all_values
where value_field not in (
    'very_small','small','medium','large','very_large'
)



  
  
      
    ) dbt_internal_test