with
    source as (
        select *
        from {{ source('sales', 'store') }}
    )

    , renamed as (
        select
            cast(businessentityid as int) as nk_store
            , trim(name) as nm_store
        from source
    )

select *
from renamed
