
  
    

create or replace transient table dw_nasa_dev.dbt_nasa.mart__nasa_solar_flare_class_summary
    
    
    
    as (-- Solar flare count grouped by year, month, and NOAA class category.
-- Useful for time-series visualizations of flare intensity trends.
SELECT
    event_year,
    event_month,
    class_category,
    COUNT(*)                                AS flare_count
FROM dw_nasa_dev.dbt_nasa.mart__nasa_donki_solar_flare
GROUP BY event_year, event_month, class_category
    )
;


  