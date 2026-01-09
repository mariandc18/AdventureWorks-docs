with dd as (
    select dateid,
        date
    from {{ ref('dimdate') }}
),
p as (
    select *
    from {{ ref('dimproduct') }}
),
frws as (
    select *
    from {{ ref('factreviews') }}
)
select dd.date,
    frws.storeid,
    p.category,
    p.subcategory,
    p.name as productname,
    avg(frws.rating) as avg_rating,
    count(frws.reviewid) as total_reviews
from frws
    inner join dd on frws.dateid = dd.dateid
    inner join p on frws.product = p.name
group by dd.date,
    frws.storeid,
    p.category,
    p.subcategory,
    p.name