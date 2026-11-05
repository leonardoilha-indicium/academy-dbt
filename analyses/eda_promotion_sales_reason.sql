with
    fact_sales as (
        select
            nk_sales_order
            , nk_product
            , qt_order
            , vl_gross
        from {{ ref('fact_sales') }}
    )

    , dim_products as (
        select
            sk_product
            , nm_product
        from {{ ref('dim_products') }}
    )

    , promotion_reason as (
        select sk_sales_reason
        from {{ ref('dim_sales_reasons') }}
        where ds_sales_reason_type = 'Promotion'
    )

    , promotion_orders as (
        select bridge_order_sales_reasons.nk_sales_order
        from {{ ref('bridge_order_sales_reasons') }} as bridge_order_sales_reasons
        inner join promotion_reason
            on bridge_order_sales_reasons.nk_sales_reason = promotion_reason.sk_sales_reason
    )

    , units_by_product as (
        select
            dim_products.nm_product
            , count(distinct fact_sales.nk_sales_order) as qt_orders
            , sum(fact_sales.qt_order) as qt_units
            , sum(fact_sales.vl_gross) as vl_gross
        from fact_sales
        inner join promotion_orders
            on fact_sales.nk_sales_order = promotion_orders.nk_sales_order
        inner join dim_products
            on fact_sales.nk_product = dim_products.sk_product
        group by dim_products.nm_product
    )

    , ranked_products as (
        select
            nm_product
            , qt_orders
            , qt_units
            , vl_gross
            , row_number() over (order by qt_units desc, nm_product) as nr_rank
        from units_by_product
    )

select
    nr_rank
    , nm_product
    , qt_orders
    , qt_units
    , round(vl_gross, 2) as vl_gross
from ranked_products
where nr_rank <= 10
order by nr_rank
