{{ config(materialized = 'table') }}
select businessentityid,
    departmentid,
    shiftid,
    startdate,
    enddate
from {{ source('bronze', 'hr_employeedepartmenthistory') }}