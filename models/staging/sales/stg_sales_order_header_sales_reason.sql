with
    source as (
        select *
        from {{ source('sales', 'salesorderheadersalesreason') }}
    )

    , renamed as (
        select
            cast(salesorderid as int) as nk_sales_order
            , cast(salesreasonid as int) as nk_sales_reason
        from source
    )

select *
from renamed
