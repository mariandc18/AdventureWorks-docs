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
dimscrapreason as (
    select *
    from { { ref('dimscrapreason') } }
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
        fwr.actualresourcehrs,
        fwr.plannedcost,
        fwr.actualcost,
        fwo.scrappedqty,
        fwo.orderqty,
        fwo.is_late,
        dsr.name as scrap_reason,
        case
            when fwo.scrappedqty > 0 then 1
            else 0
        end as has_defect
    from factworkorderrouting fwr
        inner join factworkorder fwo on fwr.workorderid = fwo.workorderid
        inner join dimproduct dp on fwr.productid = dp.productid
        inner join dimlocation dl on fwr.locationid = dl.locationid
        left join dimdate dd on fwo.duedateid = dd.dateid
        left join dimscrapreason dsr on fwo.scrapreasonid = dsr.scrapreasonid
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
    round(
        count(
            distinct case
                when is_late = 1 then workorderid
            end
        ) * 100.0 / nullif(count(distinct workorderid), 0),
        2
    ) as late_rate_pct,
    round(sum(plannedcost), 2) as total_planned_cost,
    round(sum(actualcost), 2) as total_actual_cost,
    round(sum(actualcost) - sum(plannedcost), 2) as cost_variance,
    round(
        (sum(actualcost) - sum(plannedcost)) * 100.0 / nullif(sum(plannedcost), 0),
        2
    ) as cost_variance_pct,
    round(sum(actualresourcehrs), 2) as total_resource_hours,
    round(avg(actualresourcehrs), 2) as avg_resource_hours,
    coalesce(
        max(
            case
                when scrap_reason is not null then scrap_reason
            end
        ),
        case
            when max(scrappedqty) > 0 then 'Rechazo sin causa'
            else 'Sin rechazo'
        end
    ) as primary_scrap_reason
from routing_detail
group by operation_date,
    operationsequence,
    location_name,
    product_name
order by operation_date desc,
    defect_rate_pct desc,
    cost_variance desc