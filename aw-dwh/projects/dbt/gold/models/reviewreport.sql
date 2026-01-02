with sr as (
    select *
    from {{ ref('dimstorereviews') }}
),
usr as (
    select *
    from {{ ref('dimuser') }}
),
dd as (
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
    sr.name as storename,
    p.category,
    p.subcategory,
    p.name as productname,
    avg(frws.rating) as avg_rating,
    count(frws.reviewid) as total_reviews
from frws
    inner join sr on frws.storeid = sr.storeid
    inner join usr on frws.userid = usr.userid
    inner join dd on frws.dateid = dd.dateid
    inner join p on frws.product = p.name
group by dd.date,
    sr.name,
    p.category,
    p.subcategory,
    p.name