SELECT
    flr_id,
    begin_time,
    class_type,
    LEFT(class_type, 1)                     AS class_category,
    DATE(begin_time)                        AS event_date,
    EXTRACT(YEAR FROM begin_time)           AS event_year,
    EXTRACT(MONTH FROM begin_time)          AS event_month,
    DAYOFWEEK(begin_time)                   AS event_day_of_week
FROM {{ ref('stg__nasa_donki_solar_flare') }}
