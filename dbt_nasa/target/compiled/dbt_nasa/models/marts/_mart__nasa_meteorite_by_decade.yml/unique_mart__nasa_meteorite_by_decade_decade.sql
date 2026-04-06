
    
    

select
    decade as unique_field,
    count(*) as n_records

from dw_nasa_dev.dbt_nasa.mart__nasa_meteorite_by_decade
where decade is not null
group by decade
having count(*) > 1


