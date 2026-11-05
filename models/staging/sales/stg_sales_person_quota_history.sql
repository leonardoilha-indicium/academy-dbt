with
    source as (
        select *
        from {{ source('sales', 'salespersonquotahistory') }}
    )

    , renamed as (
        select
            cast(businessentityid as int) as nk_sales_person
            , cast(quotadate as date) as dt_quota
            , cast(salesquota as decimal(19, 4)) as vl_sales_quota
        from source
    )

select *
from renamed
