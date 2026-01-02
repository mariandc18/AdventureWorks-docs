{ { config(materialized = 'table') } } with sr as (
    select *
    from { { ref('dimstorereviews') } }
),
usr as (
    select *
    from { { ref('dimuser') } }
),
dd as (
    select dateid,
        date
    from { { ref('dimdate') } }
),
reviews as (
    select { { dbt_utils.generate_surrogate_key(["id"]) } } as reviewid,
        id as altreviewid,
        userId,
        storeId,
        product,
        rating,
        date
    from { { source('silver', 'silver_reviews') } }
)
select r.reviewid,
    r.altreviewid,
    u.userid,
    s.storeid,
    d.dateid,
    r.product,
    r.rating
from reviews r
    inner join usr u on r.userId = u.altuserid
    inner join sr s on r.storeId = s.altstoreid
    inner join dd d on r.date = d.date