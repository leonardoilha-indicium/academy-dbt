with
    source as (
        select *
        from {{ source('sales', 'salesperson') }}
    )

    , renamed as (
        select
            cast(businessentityid as int) as nk_sales_person
            , cast(territoryid as int) as nk_territory
        from source
    )

select *
from renamed
