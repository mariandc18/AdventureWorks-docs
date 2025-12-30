{{ config(materialized ='table') }}

select 
    departmentid,
    name,
    groupname
from {{ source('bronze', 'hr_department') }}
