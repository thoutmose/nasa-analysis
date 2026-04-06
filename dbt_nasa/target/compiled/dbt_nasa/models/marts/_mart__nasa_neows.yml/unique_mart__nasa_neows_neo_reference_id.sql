
    
    

select
    neo_reference_id as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_neows
where neo_reference_id is not null
group by neo_reference_id
having count(*) > 1


