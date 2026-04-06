SELECT
    gst_id,
    start_time
FROM
    {{ ref('base_nasa_donki_gst_nasa_donki_gst_response') }}
