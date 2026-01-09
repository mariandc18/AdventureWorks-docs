{{ config(materialized = 'table') }}

with factonlinesale as (
    select * from {{ ref('factonlinesale') }}
),
dimpromotion as (
    select * from {{ ref('dimpromotion') }}
),
dimproduct as (
    select * from {{ ref('dimproduct') }}
),
dimdate as (
    select * from {{ ref('dimdate') }}
),
salesorderheader as (
    select * from {{ source('silver','salesorderheader') }}
),
salesorderdetail as (
    select * from {{ source('silver','salesorderdetail') }}
),

sales as (
    select 
        f.productid,
        p.specialofferid,
        p.promotionid,   
        p.description,
        p.discountpct,
        p.type,
        p.category as promo_category,
        p.startdate,
        p.enddate,
        p.minqty,
        p.maxqty,

        sum(f.salesamount) as total_sales,
        sum(f.costamount) as total_cost,
        sum(f.salesamount - f.costamount) as total_margin,

        count(distinct case when p.specialofferid != 1 then p.specialofferid end) as times_promoted,

        sum(case when p.specialofferid != 1 then f.salesamount else 0 end) as sales_with_promo,
        sum(case when p.specialofferid = 1 or p.specialofferid is null then f.salesamount else 0 end) as sales_without_promo,

        sum(case when p.specialofferid != 1 then f.salesamount - f.costamount else 0 end) as margin_with_promo,
        sum(case when p.specialofferid = 1 or p.specialofferid is null then f.salesamount - f.costamount else 0 end) as margin_without_promo

    from factonlinesale f
    left join dimpromotion p
        on f.specialofferid = p.specialofferid  
    group by
        f.productid,
        p.specialofferid,
        p.promotionid,
        p.description,
        p.discountpct,
        p.type,
        p.category,
        p.startdate,
        p.enddate,
        p.minqty,
        p.maxqty
),


cancellations as (
    select 
        dp.productid,
        sum(sod.orderqty) as units_cancelled
    from salesorderheader soh
    inner join salesorderdetail sod
        on soh.salesorderid = sod.salesorderid
    inner join dimproduct dp
        on dp.altproductid = sod.productid
    where soh.status = 6  
    group by dp.productid
)

select 
    dp.productid,
    dp.name as productname,
    dp.category,
    dp.subcategory,

    s.specialofferid,
    s.promotionid,
    s.description as promotion_description,
    s.discountpct,
    s.type as promotion_type,
    s.promo_category,
    s.startdate,
    s.enddate,
    s.minqty,
    s.maxqty,

    s.total_sales,
    s.total_cost,
    s.total_margin,
    s.margin_with_promo,
    s.margin_without_promo,

    s.times_promoted,
    s.sales_with_promo,
    s.sales_without_promo,

    coalesce(c.units_cancelled, 0) as units_cancelled,

    case 
        when s.startdate is not null and s.enddate is not null
        then date_diff(
            'day',
            cast(s.startdate as date),
            cast(s.enddate as date)
        )
        else null
    end as promo_duration_days

from sales s
inner join dimproduct dp
    on dp.productid = s.productid
left join cancellations c
    on c.productid = s.productid