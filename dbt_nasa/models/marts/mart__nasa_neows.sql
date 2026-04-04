SELECT
    id,
    name
FROM {{ ref('stg__nasa_neows') }}
