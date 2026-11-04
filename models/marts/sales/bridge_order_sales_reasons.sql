with
    order_header as (
        select nk_sales_order
        from {{ ref('stg_sales_order_header') }}
    )

    , order_sales_reason as (
        select *
        from {{ ref('stg_sales_order_header_sales_reason') }}
    )

    /* Orders without any reason get the "No reason" member (-1), so every order appears */
    , order_reasons as (
        select
            order_header.nk_sales_order
            , coalesce(order_sales_reason.nk_sales_reason, -1) as nk_sales_reason
        from order_header
        left join order_sales_reason
            on order_header.nk_sales_order = order_sales_reason.nk_sales_order
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['nk_sales_order', 'nk_sales_reason']) }} as sk_order_sales_reason
            , nk_sales_order
            , {{ dbt_utils.generate_surrogate_key(['nk_sales_reason']) }} as fk_sales_reason
        from order_reasons
    )

select *
from final
