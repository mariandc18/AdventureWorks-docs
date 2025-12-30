{{ config(materialized = 'table') }}
select id,
    userId,
    storeId,
    product,
    rating,
    date
from {{ source ('bronze', 'reviews_reviews') }}