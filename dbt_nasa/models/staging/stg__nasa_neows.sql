SELECT
    id,
    name 
FROM
    {{ source('nasa_neows', 'nasa_neows_response') }}