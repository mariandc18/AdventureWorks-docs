select {{ dbt_utils.generate_surrogate_key(
        [
        "'reviews'",
        "id"
    ]
    ) }} as storeid,
    id as altstoreid,
    name
from {{ source('silver', 'silver_stores') }}