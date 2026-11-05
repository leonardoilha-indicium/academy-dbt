with
    sales_reason as (
        select *
        from {{ ref('stg_sales_reason') }}
    )

    , unknown_member as (
        select
            -1 as nk_sales_reason
            , 'No reason' as nm_sales_reason
            , 'No reason' as ds_sales_reason_type
    )

    , unioned as (
        select
            nk_sales_reason
            , nm_sales_reason
            , ds_sales_reason_type
        from sales_reason

        union all

        select
            nk_sales_reason
            , nm_sales_reason
            , ds_sales_reason_type
        from unknown_member
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['nk_sales_reason']) }} as sk_sales_reason
            , nk_sales_reason
            , nm_sales_reason
            , ds_sales_reason_type
        from unioned
    )

select *
from final
