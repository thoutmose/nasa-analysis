-- Asserts that no geomagnetic storm event has a start_time in the future.
-- Future-dated events would indicate a data quality issue in the DONKI feed.
SELECT
    gst_id,
    start_time
FROM dw_nasa_dev.dbt_nasa.mart__nasa_donki_gst
WHERE start_time > CURRENT_TIMESTAMP()