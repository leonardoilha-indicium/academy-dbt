with
    fact_sales as (
        select
            nk_sales_order
            , dt_order
            , is_online_order
            , vl_gross
            , vl_net
        from {{ ref('fact_sales') }}
    )

    , dim_dates as (
        select
            sk_date
            , nr_year
            , nr_month
            , ds_year_month
        from {{ ref('dim_dates') }}
    )

    , sales_by_month as (
        select
            dim_dates.nr_year
            , dim_dates.nr_month
            , dim_dates.ds_year_month
            , count(distinct fact_sales.nk_sales_order) as qt_orders
            , count(distinct case when fact_sales.is_online_order then fact_sales.nk_sales_order end) as qt_online_orders
            , sum(fact_sales.vl_gross) as vl_gross
            , sum(fact_sales.vl_net) as vl_net
        from fact_sales
        inner join dim_dates
            on fact_sales.dt_order = dim_dates.sk_date
        group by
            dim_dates.nr_year
            , dim_dates.nr_month
            , dim_dates.ds_year_month
    )

select
    ds_year_month
    , qt_orders
    , qt_online_orders
    , qt_orders - qt_online_orders as qt_salesperson_orders
    , round(vl_gross, 2) as vl_gross
    , round(vl_net, 2) as vl_net
    , round(vl_net / qt_orders, 2) as vl_net_per_order
from sales_by_month
order by nr_year, nr_month
