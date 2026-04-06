SELECT
    id,
    name,
    nametype,
    recclass,
    mass                                    AS mass_grams,
    fall,
    TRY_CAST(NULLIF(year, '') AS INTEGER)   AS landing_year,
    reclat                                  AS latitude,
    reclong                                 AS longitude,
    CASE
        WHEN mass < 10                         THEN 'very_small'
        WHEN mass < 100                        THEN 'small'
        WHEN mass < 1000                       THEN 'medium'
        WHEN mass < 10000                      THEN 'large'
        ELSE                                        'very_large'
    END                                     AS mass_category
FROM dw_nasa_dev.dbt_nasa.stg__nasa_meteorite_landings
WHERE mass IS NOT NULL