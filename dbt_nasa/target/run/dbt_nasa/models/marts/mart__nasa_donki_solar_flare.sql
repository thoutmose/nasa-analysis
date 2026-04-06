
  
    

create or replace transient table dw_nasa_dev.dbt_nasa.mart__nasa_donki_solar_flare
    
    
    
    as (SELECT
    flr_id,
    begin_time,
    class_type,
    LEFT(class_type, 1)                     AS class_category,
    DATE(begin_time)                        AS event_date,
    EXTRACT(YEAR FROM begin_time)           AS event_year,
    EXTRACT(MONTH FROM begin_time)          AS event_month,
    DAYOFWEEK(begin_time)                   AS event_day_of_week
FROM dw_nasa_dev.dbt_nasa.stg__nasa_donki_solar_flare
    )
;


  