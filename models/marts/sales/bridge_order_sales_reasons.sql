with
    order_header as (
        select nk_sales_order
        from {{ ref('stg_sales_order_header') }}
    )

    , order_sales_reason as (
        select *
        from {{ ref('stg_sales_order_header_sales_reason') }}
    )

    , dim_sales_reasons as (
        select
            sk_sales_reason
            , nk_sales_reason
        from {{ ref('dim_sales_reasons') }}
    )

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
            {{ dbt_utils.generate_surrogate_key(['order_reasons.nk_sales_order', 'order_reasons.nk_sales_reason']) }} as sk_order_sales_reason
            , order_reasons.nk_sales_order
            , dim_sales_reasons.sk_sales_reason as fk_sales_reason
        from order_reasons
        inner join dim_sales_reasons
            on order_reasons.nk_sales_reason = dim_sales_reasons.nk_sales_reason
    )

select *
from final
