select {{ dbt_utils.generate_surrogate_key(["id"
    ]) }} as userid,
    id as altuserid,
    firstname,
    lastname,
    email,
    birthdate
from {{ source('silver', 'silver_users') }}