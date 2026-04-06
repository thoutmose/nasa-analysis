
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        class_category as value_field,
        count(*) as n_records

    from dw_nasa_dev.dbt_nasa.mart__nasa_solar_flare_class_summary
    group by class_category

)

select *
from all_values
where value_field not in (
    'X','M','C','B','A'
)



  
  
      
    ) dbt_internal_test