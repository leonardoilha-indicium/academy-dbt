with
    source as (
        select *
        from {{ source('sales', 'customer') }}
    )

    , renamed as (
        select
            cast(customerid as int) as customer_id
            , cast(personid as int) as person_id
            , cast(storeid as int) as store_id
            , cast(territoryid as int) as territory_id
        from source
    )

select *
from renamed
