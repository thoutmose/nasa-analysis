SELECT
    flr_id,
    begin_time,
    class_type
FROM
    {{ source('nasa_donki_solar_flare', 'nasa_donki_response') }}
