with scpr as (
    select *
    from {{ ref('dimscrapreason') }}
),
p as (
    select *
    from {{ ref('dimproduct') }}
),
dd as (
    select dateid,
        date
    from {{ ref('dimdate') }}
),
workorder as (
    select {{ dbt_utils.generate_surrogate_key(["workorderid"]) }} as workorderid,
        workorderid as altworkorderid,
        orderqty,
        scrappedqty,
        stockedqty,
        productid,
        scrapreasonid,
        startdate,
        enddate,
        duedate
    from {{ source('silver', 'workorder') }}
)
select wo.workorderid,
    wo.altworkorderid,
    wo.orderqty,
    wo.scrappedqty,
    wo.stockedqty,
    pt.productid,
    coalesce(sr.scrapreasonid, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as scrapreasonid,
    sd.dateid as startdateid,
    ed.dateid as enddateid,
    dd.dateid as duedateid,
    case
        when wo.enddate > wo.duedate then 1
        else 0
    end as is_late
from workorder wo
    inner join p pt on wo.productid = pt.altproductid
    left join scpr sr on wo.scrapreasonid = sr.altscrapreasonid
    left join dd sd on wo.startdate = sd.date
    left join dd ed on wo.enddate = ed.date
    left join dd dd on wo.duedate = dd.date