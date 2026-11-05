with
    order_header as (
        select *
        from {{ ref('stg_sales_order_header') }}
    )

    , address as (
        select *
        from {{ ref('stg_address') }}
    )

    /* Grain: one row per order. Freight and tax exist only here, never at order line level */
    , final as (
        select
            order_header.nk_sales_order as sk_sales_order
            , order_header.nk_sales_order
            , order_header.nk_customer
            , coalesce(order_header.nk_sales_person, -1) as nk_sales_person
            , order_header.nk_territory
            , order_header.nk_ship_method
            , coalesce(order_header.nk_credit_card, -1) as nk_credit_card
            , order_header.nk_order_status
            , {{ dbt_utils.generate_surrogate_key(['address.nk_state_province', 'address.nm_city']) }} as fk_geography
            , order_header.dt_order
            , order_header.dt_due
            , order_header.dt_ship
            , order_header.is_online_order
            , datediff(order_header.dt_ship, order_header.dt_order) as qt_days_to_ship
            , order_header.vl_subtotal
            , order_header.vl_tax
            , order_header.vl_freight
            , order_header.vl_total_due
        from order_header
        inner join address
            on order_header.nk_ship_to_address = address.nk_address
    )

select *
from final
