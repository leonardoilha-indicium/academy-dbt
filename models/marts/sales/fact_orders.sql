with
    order_header as (
        select *
        from {{ ref('stg_sales_order_header') }}
    )

    , address as (
        select *
        from {{ ref('stg_address') }}
    )

    , dim_customers as (
        select
            sk_customer
            , nk_customer
        from {{ ref('dim_customers') }}
    )

    , dim_salespersons as (
        select
            sk_sales_person
            , nk_sales_person
        from {{ ref('dim_salespersons') }}
    )

    , dim_territories as (
        select
            sk_territory
            , nk_territory
        from {{ ref('dim_territories') }}
    )

    , dim_ship_methods as (
        select
            sk_ship_method
            , nk_ship_method
        from {{ ref('dim_ship_methods') }}
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

    , orders as (
        select
            order_header.nk_sales_order
            , order_header.nk_customer
            , coalesce(order_header.nk_sales_person, -1) as nk_sales_person
            , order_header.nk_territory
            , order_header.nk_ship_method
            , coalesce(order_header.nk_credit_card, -1) as nk_credit_card
            , order_header.nk_order_status
            , address.nk_state_province
            , address.nm_city
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

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['orders.nk_sales_order']) }} as sk_sales_order
            , orders.nk_sales_order
            , dim_customers.sk_customer as fk_customer
            , dim_salespersons.sk_sales_person as fk_sales_person
            , dim_territories.sk_territory as fk_territory
            , dim_ship_methods.sk_ship_method as fk_ship_method
            , dim_credit_cards.sk_credit_card as fk_credit_card
            , dim_order_statuses.sk_order_status as fk_order_status
            , dim_geographies.sk_geography as fk_geography
            , dim_order_dates.sk_date as fk_order_date
            , dim_due_dates.sk_date as fk_due_date
            , dim_ship_dates.sk_date as fk_ship_date
            , orders.dt_order
            , orders.dt_due
            , orders.dt_ship
            , orders.is_online_order
            , orders.qt_days_to_ship
            , orders.vl_subtotal
            , orders.vl_tax
            , orders.vl_freight
            , orders.vl_total_due
        from orders
        inner join dim_customers
            on orders.nk_customer = dim_customers.nk_customer
        inner join dim_salespersons
            on orders.nk_sales_person = dim_salespersons.nk_sales_person
        inner join dim_territories
            on orders.nk_territory = dim_territories.nk_territory
        inner join dim_ship_methods
            on orders.nk_ship_method = dim_ship_methods.nk_ship_method
        inner join dim_credit_cards
            on orders.nk_credit_card = dim_credit_cards.nk_credit_card
        inner join dim_order_statuses
            on orders.nk_order_status = dim_order_statuses.nk_order_status
        inner join dim_geographies
            on orders.nk_state_province = dim_geographies.nk_state_province
            and orders.nm_city = dim_geographies.nm_city
        inner join dim_dates as dim_order_dates
            on orders.dt_order = dim_order_dates.dt_calendar
        inner join dim_dates as dim_due_dates
            on orders.dt_due = dim_due_dates.dt_calendar
        inner join dim_dates as dim_ship_dates
            on orders.dt_ship = dim_ship_dates.dt_calendar
    )

select *
from final
