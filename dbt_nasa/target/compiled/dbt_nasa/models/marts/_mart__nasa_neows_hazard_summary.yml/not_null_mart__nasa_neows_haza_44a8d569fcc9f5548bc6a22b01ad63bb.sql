
    
    



select is_potentially_hazardous_asteroid
from dw_nasa_dev.dbt_nasa.mart__nasa_neows_hazard_summary
where is_potentially_hazardous_asteroid is null


