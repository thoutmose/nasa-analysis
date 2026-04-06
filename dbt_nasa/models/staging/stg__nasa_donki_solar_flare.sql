SELECT
    flr_id,
    begin_time,
    peak_time,
    end_time,
    class_type,
    source_location
FROM
    {{ ref('base_nasa_donki_solar_flare_nasa_donki_response') }}
