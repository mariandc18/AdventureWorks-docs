{ { config(materialized = 'table') } } with factworkorder as (
    select *
    from { { ref('factworkorder') } }
),
factworkorderrouting as (
    select *
    from { { ref('factworkorderrouting') } }
),
dimproduct as (
    select *
    from { { ref('dimproduct') } }
),
dimlocation as (
    select *
    from { { ref('dimlocation') } }
),
dimdate as (
    select *
    from { { ref('dimdate') } }
),
routing_detail as (
    select fwr.workorderid,
        fwr.operationsequence,
        fwr.locationid,
        dl.name as location_name,
        dp.name as product_name,
        dd.date as operation_date,
        fwr.plannedcost,
        fwr.actualcost,
        fwo.scrappedqty,
        fwo.orderqty,
        fwo.is_late,
        case
            when fwo.scrappedqty > 0 then 1
            else 0
        end as has_defect
    from factworkorderrouting fwr
        inner join factworkorder fwo on fwr.workorderid = fwo.workorderid
        inner join dimproduct dp on fwr.productid = dp.productid
        inner join dimlocation dl on fwr.locationid = dl.locationid
        left join dimdate dd on fwo.duedateid = dd.dateid
)
select operationsequence,
    operation_date,
    location_name,
    product_name,
    count(distinct workorderid) as total_orders,
    count(
        distinct case
            when has_defect = 1 then workorderid
        end
    ) as orders_with_defects,
    count(
        distinct case
            when is_late = 1 then workorderid
        end
    ) as late_orders,
    round(sum(plannedcost), 2) as total_planned_cost,
    round(sum(actualcost), 2) as total_actual_cost
from routing_detail
group by operation_date,
    operationsequence,
    location_name,
    product_name