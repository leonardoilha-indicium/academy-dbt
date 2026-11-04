with
    source as (
        select *
        from {{ source('sales', 'customer') }}
    )

    , renamed as (
        select
            cast(customerid as int) as nk_customer
            , cast(personid as int) as nk_person
            , cast(storeid as int) as nk_store
            , cast(territoryid as int) as nk_territory
        from source
    )

select *
from renamed
