with
    source as (
        select *
        from {{ source('sales', 'store') }}
    )

    , renamed as (
        select
            cast(businessentityid as int) as store_id
            , trim(name) as store_name
        from source
    )

select *
from renamed
