with p as (
    select *
    from {{ ref('dimproduct') }}
),
loc as (
    select *
    from {{ ref('dimlocation') }}
),
dd as (
    select date,
        dateid
    from {{ ref('dimdate') }}
),
wo as (
    select {{ dbt_utils.generate_surrogate_key(["workorderid"]) }} as workorderid,
        workorderid as altworkorderid,
        productid,
        startdate,
        enddate,
        duedate
    from {{ source('silver', 'workorder') }}
),
wor as (
    select {{ dbt_utils.generate_surrogate_key(["workorderid","operationsequence"]) }} as workorderroutingid,
        workorderid,
        productid,
        operationsequence,
        locationid,
        scheduledstartdate,
        scheduledenddate,
        actualstartdate,
        actualenddate,
        actualresourcehrs,
        plannedcost,
        actualcost
    from {{ source('silver', 'workorderrouting') }}
)
select wor.workorderroutingid,
    wo.workorderid,
    wor.operationsequence,
    p.productid,
    loc.locationid,
    sd.dateid as scheduledstartdateid,
    ed.dateid as scheduledenddateid,
    asd.dateid as actualstartdateid,
    aed.dateid as actualenddateid,
    wor.actualresourcehrs,
    wor.plannedcost,
    wor.actualcost
from wor
    inner join wo on wor.workorderid = wo.altworkorderid
    inner join p on wor.productid = p.altproductid
    inner join loc on wor.locationid = loc.altlocationid
    left join dd sd on wor.scheduledstartdate = sd.date
    left join dd ed on wor.scheduledenddate = ed.date
    left join dd asd on wor.actualstartdate = asd.date
    left join dd aed on wor.actualenddate = aed.date