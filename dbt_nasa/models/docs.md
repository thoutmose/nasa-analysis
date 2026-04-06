{% docs stg__nasa_neows %}
Staged Near Earth Object Web Service (NEOWS) data ingested from NASA's NeoWs REST API
via dlt. Cleans and selects key fields representing near-Earth asteroids, including
orbital hazard flags and estimated physical dimensions in metres.
{% enddocs %}

{% docs stg__nasa_donki_gst %}
Staged Geomagnetic Storm (GST) events from NASA's DONKI API, ingested via dlt.
Each row represents a discrete geomagnetic storm event identified by NASA.
{% enddocs %}

{% docs stg__nasa_donki_solar_flare %}
Staged Solar Flare (FLR) events from NASA's DONKI API, ingested via dlt.
Each row represents a discrete solar flare event with NOAA classification metadata.
{% enddocs %}

{% docs stg__nasa_meteorite_landings %}
Staged NASA Meteorite Landings dataset ingested from NASA Open Data (CSV) via dlt.
Contains historical records of meteorite impacts worldwide sourced from the
Meteoritical Society database.
{% enddocs %}

{% docs mart__nasa_neows %}
Analytics-ready Near Earth Object data. Exposes key physical and hazard attributes
for near-Earth asteroids passed directly from the staging layer.
{% enddocs %}

{% docs mart__nasa_donki_gst %}
Analytics-ready Geomagnetic Storm data enriched with date-part columns (year, month,
day of week) to facilitate time-based analysis and trend reporting in Grafana.
{% enddocs %}

{% docs mart__nasa_donki_solar_flare %}
Analytics-ready Solar Flare data enriched with a single-letter NOAA class category
(X, M, C, B, A) and date-part columns for temporal analysis and intensity trending.
{% enddocs %}

{% docs mart__nasa_meteorite_landings %}
Analytics-ready Meteorite Landings data with typed columns and a bucketed mass
category derived from raw mass measurements in grams. Records with null mass are
excluded.
{% enddocs %}

{% docs col_neo_id %}
Unique numeric identifier assigned by NASA's Jet Propulsion Laboratory (JPL)
to each near-Earth object in the Small-Body Database.
{% enddocs %}

{% docs col_is_potentially_hazardous_asteroid %}
Boolean flag set by NASA when an asteroid has an orbit that could bring it within
0.05 AU of Earth and has an estimated diameter larger than 140 m.
{% enddocs %}

{% docs col_estimated_diameter_min %}
Minimum estimated diameter of the asteroid in metres, derived from absolute
magnitude H assuming an average geometric albedo of 0.154.
{% enddocs %}

{% docs col_estimated_diameter_max %}
Maximum estimated diameter of the asteroid in metres, derived from absolute
magnitude H assuming an average geometric albedo of 0.154.
{% enddocs %}

{% docs col_gst_id %}
Unique DONKI identifier for the geomagnetic storm event, formatted as
YYYY-MM-DDTHH:MM:SS-GST-NNN where NNN is a zero-padded sequence number.
{% enddocs %}

{% docs col_flr_id %}
Unique DONKI identifier for the solar flare event, formatted as
YYYY-MM-DDTHH:MM:SS-FLR-NNN where NNN is a zero-padded sequence number.
{% enddocs %}

{% docs col_class_type %}
NOAA solar flare classification consisting of a letter class (X, M, C, B, A)
and a numeric multiplier, e.g. X1.5 or M2.3. Higher values indicate greater
peak X-ray flux intensity.
{% enddocs %}

{% docs col_class_category %}
Single-letter NOAA class extracted from class_type. Ordered by intensity:
X (extreme) > M (major) > C (common) > B (below average) > A (minimal).
{% enddocs %}

{% docs col_mass_grams %}
Mass of the meteorite in grams as recorded in the Meteoritical Society database.
Rows with null mass are excluded from the mart model.
{% enddocs %}

{% docs col_mass_category %}
Bucketed mass classification derived from mass_grams:
very_small (< 10 g), small (10–100 g), medium (100–1 000 g),
large (1 000–10 000 g), very_large (> 10 000 g).
{% enddocs %}

{% docs col_landing_year %}
Integer year in which the meteorite was observed to fall or was found, cast from
the raw string field using TRY_CAST. Returns NULL when the original value is empty
or non-numeric.
{% enddocs %}

{% docs col_absolute_magnitude_h %}
Absolute magnitude (H) of the asteroid, a measure of intrinsic brightness used
to estimate physical size. Lower values indicate larger or brighter objects.
{% enddocs %}

{% docs col_peak_time %}
Timestamp of peak X-ray flux intensity for the solar flare event as reported by
NASA DONKI. May be NULL for events still in progress at ingestion time.
{% enddocs %}

{% docs col_end_time %}
Timestamp when the solar flare event ended as reported by NASA DONKI. May be NULL
for events still in progress at ingestion time.
{% enddocs %}

{% docs col_source_location %}
Active region location on the solar disk in Stonyhurst heliographic coordinates
(e.g. N15W30). Identifies the originating sunspot region of the flare.
{% enddocs %}

{% docs col_decade %}
The decade in which the meteorite was recorded, expressed as the floor year
(e.g. 1970 represents the 1970–1979 decade).
{% enddocs %}

{% docs mart__nasa_solar_flare_class_summary %}
Monthly count of solar flare events grouped by NOAA class category (X, M, C, B, A).
Designed for time-series and bar-chart visualizations of solar activity trends.
{% enddocs %}

{% docs mart__nasa_space_weather_monthly %}
Monthly count of geomagnetic storm events and solar flare events combined into a
single row per year/month. Enables cross-dataset space-weather trend dashboards.
{% enddocs %}

{% docs mart__nasa_neows_hazard_summary %}
Aggregate asteroid statistics split by hazard classification. Returns one row per
hazard flag value with count, average diameter, and magnitude statistics for use
in pie-chart and stat-panel visualizations.
{% enddocs %}

{% docs mart__nasa_meteorite_by_decade %}
Meteorite landing counts and mass statistics aggregated by decade. Returns one row
per decade with landing count, average mass, total mass, and class diversity for
historical bar-chart and timeline visualizations.
{% enddocs %}
