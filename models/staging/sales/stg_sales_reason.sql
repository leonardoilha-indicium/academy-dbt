with
    source as (
        select *
        from {{ source('sales', 'salesreason') }}
    )

    , renamed as (
        select
            cast(salesreasonid as int) as sales_reason_id
            , trim(name) as sales_reason_name
            , trim(reasontype) as sales_reason_type
        from source
    )

select *
from renamed
