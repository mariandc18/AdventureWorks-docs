{{ config(materialized = 'table') }}

with dd as (
    select 
        dateid,
        date
    from {{ ref('dimdate') }}
),

reviews as (
    select 
        {{ dbt_utils.generate_surrogate_key(["id"]) }} as reviewid,
        id as altreviewid,
        userid,   
        storeid,     
        product,
        rating,
        date
    from {{ source('silver', 'silver_reviews') }}
)

select 
    r.reviewid,
    r.altreviewid,
    r.userid,
    r.storeid,
    d.dateid,
    r.product,
    r.rating
from reviews r
left join dd d 
    on r.date = d.date
