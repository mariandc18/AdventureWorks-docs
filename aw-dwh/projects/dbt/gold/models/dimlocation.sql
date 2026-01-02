select {{ dbt_utils.generate_surrogate_key(["locationid"
    ]) }} as locationid,
    locationid as altlocationid,
    name,
    costrate,
    availability
from {{ source('silver', 'location') }}