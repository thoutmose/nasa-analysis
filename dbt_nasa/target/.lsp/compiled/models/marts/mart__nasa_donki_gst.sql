SELECT
    gst_id,
    start_time,
    DATE(start_time)                        AS event_date,
    EXTRACT(YEAR FROM start_time)           AS event_year,
    EXTRACT(MONTH FROM start_time)          AS event_month,
    DAYOFWEEK(start_time)                   AS event_day_of_week
FROM dw_nasa_dev.dbt_nasa.stg__nasa_donki_gst