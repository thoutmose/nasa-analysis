
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    gst_id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_donki_gst
where gst_id is not null
group by gst_id
having count(*) > 1



  
  
      
    ) dbt_internal_test