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

    , product as (
        select
            nk_product
            , vl_standard_cost
        from {{ ref('stg_product') }}
    )

    , product_cost_history as (
        select *
        from {{ ref('stg_product_cost_history') }}
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
            , coalesce(product_cost_history.vl_standard_cost, product.vl_standard_cost) as vl_unit_cost
        from order_detail
        inner join order_header
            on order_detail.nk_sales_order = order_header.nk_sales_order
        inner join address
            on order_header.nk_ship_to_address = address.nk_address
        inner join product
            on order_detail.nk_product = product.nk_product
        left join product_cost_history
            on order_detail.nk_product = product_cost_history.nk_product
            and order_header.dt_order >= product_cost_history.dt_start
            and (
                product_cost_history.dt_end is null
                or order_header.dt_order <= product_cost_history.dt_end
            )
    )

    , amounts as (
        select
            *
            , cast(vl_unit_price * qt_order as decimal(18, 4)) as vl_gross
        from order_lines
    )

    , margins as (
        select
            *
            , cast(vl_gross * pc_unit_price_discount as decimal(18, 8)) as vl_discount
            , cast(vl_gross - (vl_gross * pc_unit_price_discount) as decimal(18, 8)) as vl_net
            , cast(vl_unit_cost * qt_order as decimal(18, 4)) as vl_cost
        from amounts
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['margins.nk_sales_order_detail']) }} as sk_sales_order_detail
            , margins.nk_sales_order_detail
            , margins.nk_sales_order
            , dim_products.sk_product as fk_product
            , dim_customers.sk_customer as fk_customer
            , dim_dates.sk_date as fk_order_date
            , dim_geographies.sk_geography as fk_geography
            , dim_credit_cards.sk_credit_card as fk_credit_card
            , dim_order_statuses.sk_order_status as fk_order_status
            , margins.dt_order
            , margins.is_online_order
            , margins.qt_order
            , margins.vl_gross
            , margins.vl_discount
            , margins.vl_net
            , margins.vl_cost
            , cast(margins.vl_net - margins.vl_cost as decimal(18, 8)) as vl_margin
        from margins
        inner join dim_products
            on margins.nk_product = dim_products.nk_product
        inner join dim_customers
            on margins.nk_customer = dim_customers.nk_customer
        inner join dim_dates
            on margins.dt_order = dim_dates.dt_calendar
        inner join dim_geographies
            on margins.nk_state_province = dim_geographies.nk_state_province
            and margins.nm_city = dim_geographies.nm_city
        inner join dim_credit_cards
            on margins.nk_credit_card = dim_credit_cards.nk_credit_card
        inner join dim_order_statuses
            on margins.nk_order_status = dim_order_statuses.nk_order_status
    )

select *
from final
