{{ config(materialized = 'table') }}
select id,
    name
from {{ source('bronze', 'reviews_stores') }}