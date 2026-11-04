with
    source as (
        select *
        from {{ source('sales', 'salesorderheadersalesreason') }}
    )

    , renamed as (
        select
            cast(salesorderid as int) as sales_order_id
            , cast(salesreasonid as int) as sales_reason_id
        from source
    )

select *
from renamed
