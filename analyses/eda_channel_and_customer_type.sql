with
    fact_sales as (
        select
            nk_sales_order
            , fk_customer
            , is_online_order
            , qt_order
            , vl_gross
            , vl_net
        from {{ ref('fact_sales') }}
    )

    , dim_customers as (
        select
            sk_customer
            , ds_customer_type
        from {{ ref('dim_customers') }}
    )

    , sales_by_channel as (
        select
            fact_sales.is_online_order
            , dim_customers.ds_customer_type
            , count(distinct fact_sales.fk_customer) as qt_customers
            , count(distinct fact_sales.nk_sales_order) as qt_orders
            , sum(fact_sales.qt_order) as qt_units
            , sum(fact_sales.vl_gross) as vl_gross
            , sum(fact_sales.vl_net) as vl_net
        from fact_sales
        inner join dim_customers
            on fact_sales.fk_customer = dim_customers.sk_customer
        group by
            fact_sales.is_online_order
            , dim_customers.ds_customer_type
    )

select
    is_online_order
    , ds_customer_type
    , qt_customers
    , qt_orders
    , round(vl_gross, 2) as vl_gross
    , round(vl_gross / sum(vl_gross) over (), 4) as pc_gross_share
    , round(vl_net / qt_orders, 2) as vl_net_per_order
    , round(qt_units / qt_orders, 2) as qt_units_per_order
from sales_by_channel
order by vl_gross desc
