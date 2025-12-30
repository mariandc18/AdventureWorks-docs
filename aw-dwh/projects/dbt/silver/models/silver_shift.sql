{{ config(materialized = 'table') }}
select shiftid,
    name,
    starttime,
    endtime
from {{ source('bronze', 'hr_shift') }}