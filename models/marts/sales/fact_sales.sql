with
    order_detail as (
        select *
        from {{ ref('stg_sales_order_detail') }}
    )

    , order_header as (
        select *
        from {{ ref('stg_sales_order_header') }}
    )

    , address as (
        select *
        from {{ ref('stg_address') }}
    )

    /* Grain: one row per order line. Header and ship-to address columns are carried to the line */
    , order_lines as (
        select
            order_detail.nk_sales_order_detail
            , order_detail.nk_sales_order
            , order_detail.nk_product
            , order_header.nk_customer
            , coalesce(order_header.nk_credit_card, -1) as nk_credit_card
            , order_header.nk_order_status
            , order_header.dt_order
            , order_header.is_online_order
            , address.nk_state_province
            , address.nm_city
            , order_detail.qt_order
            , order_detail.vl_unit_price
            , order_detail.pc_unit_price_discount
        from order_detail
        inner join order_header
            on order_detail.nk_sales_order = order_header.nk_sales_order
        inner join address
            on order_header.nk_ship_to_address = address.nk_address
    )

    , amounts as (
        select
            *
            , cast(vl_unit_price * qt_order as decimal(18, 4)) as vl_gross
        from order_lines
    )

    , final as (
        select
            nk_sales_order_detail as sk_sales_order_detail
            , nk_sales_order_detail
            , nk_sales_order
            , nk_product
            , nk_customer
            , nk_credit_card
            , nk_order_status
            , {{ dbt_utils.generate_surrogate_key(['nk_state_province', 'nm_city']) }} as fk_geography
            , dt_order
            , is_online_order
            , qt_order
            , vl_gross
            , cast(vl_gross * pc_unit_price_discount as decimal(18, 8)) as vl_discount
            , cast(vl_gross - (vl_gross * pc_unit_price_discount) as decimal(18, 8)) as vl_net
        from amounts
    )

select *
from final
