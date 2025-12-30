{{ config(materialized = 'table') }}
select id,
    firstName,
    lastName,
    email,
    birthdate
from {{ source('bronze', 'reviews_users') }}