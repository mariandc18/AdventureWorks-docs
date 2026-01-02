select {{ dbt_utils.generate_surrogate_key(["scrapreasonid"
    ]) }} as scrapreasonid,
    scrapreasonid as altscrapreasonid,
    name
from {{ source('silver', 'scrapreason') }}

union all 
select {{ dbt_utils.generate_surrogate_key(["'-1'"]) }} as scrapreasonid, 
    -1 as altscrapreasonid, 
    'Unknown' as name