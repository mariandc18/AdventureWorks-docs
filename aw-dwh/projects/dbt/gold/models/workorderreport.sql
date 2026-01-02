{{ config(materialized = 'table') }}
with factworkorder as (
    select * from {{ ref('factworkorder') }}
),
factworkorderrouting as (
    select * from {{ ref('factworkorderrouting') }}
),
dimdate as (
    select * from {{ ref('dimdate') }}
),
dimproduct as ( 
    select productid, standardcost, name
    from {{ ref('dimproduct') }}
),
dimscrapreason as (
    select * from {{ ref('dimscrapreason') }}
),
routing_agg as (
    select wor.workorderid,
           coalesce(sum(wor.actualcost), 0) as total_actualcost,
           coalesce(sum(wor.plannedcost), 0) as total_plannedcost,
           coalesce(sum(wor.actualresourcehrs), 0) as total_actualhrs,
           avg(date_diff('day', dd_scheduled.date, dd_actual.date)) as avg_delay
    from factworkorderrouting wor
    left join dimdate dd_scheduled on wor.scheduledenddateid = dd_scheduled.dateid
    left join dimdate dd_actual on wor.actualenddateid = dd_actual.dateid
    group by wor.workorderid
)
select fwo.workorderid,
       fwo.altworkorderid,
       fwo.productid,
       dp.name as product_name,
       sr.name as scrapreason_name,
       dd_due.date as duedate,
       fwo.orderqty,
       fwo.scrappedqty,
       fwo.stockedqty,
       fwo.scrappedqty * dp.standardcost as scrapcost,
       case when fwo.orderqty > 0 then fwo.scrappedqty * 1.0 / fwo.orderqty else 0 end as scrap_rate,
       case when fwo.orderqty > 0 then fwo.stockedqty * 1.0 / fwo.orderqty else 0 end as yield_rate,
       fwo.is_late,
       ra.total_actualcost,
       ra.total_plannedcost,
       ra.total_actualhrs,
       ra.avg_delay,
       case when ra.total_actualcost > 0 then ra.total_plannedcost * 1.0 / ra.total_actualcost else 0 end as cost_efficiency,
       case when ra.total_actualhrs > 0 then ra.total_plannedcost * 1.0 / ra.total_actualhrs else 0 end as hrs_efficiency
from factworkorder fwo
left join routing_agg ra on fwo.workorderid = ra.workorderid
left join dimproduct dp on fwo.productid = dp.productid
left join dimscrapreason sr on fwo.scrapreasonid = sr.scrapreasonid
left join dimdate dd_due on fwo.duedateid = dd_due.dateid