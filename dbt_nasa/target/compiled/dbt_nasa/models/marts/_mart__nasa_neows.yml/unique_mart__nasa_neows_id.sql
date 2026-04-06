
    
    

select
    id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_neows
where id is not null
group by id
having count(*) > 1


