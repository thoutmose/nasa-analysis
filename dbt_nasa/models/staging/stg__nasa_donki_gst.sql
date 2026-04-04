SELECT
    gst_id,
    start_time
FROM
    {{ source('nasa_donki_gst', 'nasa_donki_gst_response') }}
