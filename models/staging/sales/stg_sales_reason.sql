with
    source as (
        select *
        from {{ source('sales', 'salesreason') }}
    )

    , renamed as (
        select
            cast(salesreasonid as int) as nk_sales_reason
            , trim(name) as nm_sales_reason
            , trim(reasontype) as ds_sales_reason_type
        from source
    )

select *
from renamed
