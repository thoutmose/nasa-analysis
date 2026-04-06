
    
    

select
    gst_id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.stg__nasa_donki_gst
where gst_id is not null
group by gst_id
having count(*) > 1


