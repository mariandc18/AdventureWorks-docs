{{ config(materialized = 'table') }}
select businessentityid,
    ratechangedate,
    rate,
    payfrequency
from {{ source('bronze', 'hr_employeepayhistory') }}