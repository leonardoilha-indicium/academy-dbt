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

    , dim_products as (
        select
            sk_product
            , nk_product
        from {{ ref('dim_products') }}
    )

    , dim_customers as (
        select
            sk_customer
            , nk_customer
        from {{ ref('dim_customers') }}
    )

    , dim_credit_cards as (
        select
            sk_credit_card
            , nk_credit_card
        from {{ ref('dim_credit_cards') }}
    )

    , dim_order_statuses as (
        select
            sk_order_status
            , nk_order_status
        from {{ ref('dim_order_statuses') }}
    )

    , dim_geographies as (
        select
            sk_geography
            , nk_state_province
            , nm_city
        from {{ ref('dim_geographies') }}
    )

    , dim_dates as (
        select
            sk_date
            , dt_calendar
        from {{ ref('dim_dates') }}
    )

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
            , cast(order_detail.vl_unit_price * order_detail.qt_order as decimal(18, 4)) as vl_gross
        from order_detail
        inner join order_header
            on order_detail.nk_sales_order = order_header.nk_sales_order
        inner join address
            on order_header.nk_ship_to_address = address.nk_address
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['order_lines.nk_sales_order_detail']) }} as sk_sales_order_detail
            , order_lines.nk_sales_order_detail
            , order_lines.nk_sales_order
            , dim_products.sk_product as fk_product
            , dim_customers.sk_customer as fk_customer
            , dim_dates.sk_date as fk_order_date
            , dim_geographies.sk_geography as fk_geography
            , dim_credit_cards.sk_credit_card as fk_credit_card
            , dim_order_statuses.sk_order_status as fk_order_status
            , order_lines.dt_order
            , order_lines.is_online_order
            , order_lines.qt_order
            , order_lines.vl_gross
            , cast(order_lines.vl_gross * order_lines.pc_unit_price_discount as decimal(18, 8)) as vl_discount
            , cast(
                order_lines.vl_gross - (order_lines.vl_gross * order_lines.pc_unit_price_discount)
                as decimal(18, 8)
            ) as vl_net
        from order_lines
        inner join dim_products
            on order_lines.nk_product = dim_products.nk_product
        inner join dim_customers
            on order_lines.nk_customer = dim_customers.nk_customer
        inner join dim_dates
            on order_lines.dt_order = dim_dates.dt_calendar
        inner join dim_geographies
            on order_lines.nk_state_province = dim_geographies.nk_state_province
            and order_lines.nm_city = dim_geographies.nm_city
        inner join dim_credit_cards
            on order_lines.nk_credit_card = dim_credit_cards.nk_credit_card
        inner join dim_order_statuses
            on order_lines.nk_order_status = dim_order_statuses.nk_order_status
    )

select *
from final
