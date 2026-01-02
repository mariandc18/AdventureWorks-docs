{ { config(materialized = 'table') } } with sales as (
    select f.productid,
        f.orderdateid,
        sum(f.salesamount) as total_sales,
        sum(f.costamount) as total_cost,
        sum(f.salesamount - f.costamount) as total_margin,
        count(
            distinct case
                when p.specialofferid != 1 then f.promotionid
            end
        ) as times_promoted,
        sum(
            case
                when p.specialofferid != 1 then f.salesamount
                else 0
            end
        ) as sales_with_promo,
        sum(
            case
                when p.specialofferid = 1
                or f.promotionid is null then f.salesamount
                else 0
            end
        ) as sales_without_promo,
        sum(
            case
                when p.specialofferid != 1 then f.orderqty
                else 0
            end
        ) as units_with_promo,
        sum(
            case
                when p.specialofferid = 1
                or f.promotionid is null then f.orderqty
                else 0
            end
        ) as units_without_promo
    from { { ref('factonlinesale') } } f
        left join { { ref('dimpromotion') } } p on f.promotionid = p.promotionid
    group by f.productid,
        f.orderdateid
),
returns as (
    select dp.productid,
        dd.dateid as orderdateid,
        count(*) as total_returns
    from { { source('silver', 'salesorderheader') } } soh
        inner join { { source('silver', 'salesorderdetail') } } sod on soh.salesorderid = sod.salesorderid
        inner join { { ref('dimproduct') } } dp on dp.altproductid = sod.productid
        inner join { { ref('dimdate') } } dd on date(soh.orderdate) = dd.date
    where soh.status in (5, 6)
    group by dp.productid,
        dd.dateid
)
select dp.productid,
    dp.name as productname,
    dp.category,
    dp.subcategory,
    s.orderdateid,
    s.total_sales,
    s.total_cost,
    s.total_margin,
    s.times_promoted,
    s.sales_with_promo,
    s.sales_without_promo,
    s.units_with_promo,
    s.units_without_promo,
    case
        when s.total_sales > 0 then s.sales_with_promo * 1.0 / s.total_sales
        else 0
    end as promo_sales_pct,
    coalesce(ret.total_returns, 0) as total_returns,
    case
        when s.total_sales > 0 then coalesce(ret.total_returns, 0) * 1.0 / s.total_sales
        else 0
    end as return_rate
from { { ref('dimproduct') } } dp
    inner join sales s on dp.productid = s.productid
    left join returns ret on dp.productid = ret.productid
    and s.orderdateid = ret.orderdateid