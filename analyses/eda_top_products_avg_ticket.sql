with
    fact_sales as (
        select
            nk_sales_order
            , nk_product
            , vl_net
        from {{ ref('fact_sales') }}
    )

    , dim_products as (
        select
            sk_product
            , nm_product
            , nm_product_category
        from {{ ref('dim_products') }}
    )

    , product_ticket as (
        select
            dim_products.nm_product
            , dim_products.nm_product_category
            , count(distinct fact_sales.nk_sales_order) as qt_orders
            , sum(fact_sales.vl_net) as vl_net
        from fact_sales
        inner join dim_products
            on fact_sales.nk_product = dim_products.sk_product
        group by
            dim_products.nm_product
            , dim_products.nm_product_category
    )

    , ranked_products as (
        select
            nm_product
            , nm_product_category
            , qt_orders
            , vl_net
            , vl_net / qt_orders as vl_avg_ticket
            , row_number() over (order by vl_net / qt_orders desc, nm_product) as nr_rank
        from product_ticket
        where qt_orders >= 30
    )

select
    nr_rank
    , nm_product
    , nm_product_category
    , qt_orders
    , round(vl_net, 2) as vl_net
    , round(vl_avg_ticket, 2) as vl_avg_ticket
from ranked_products
where nr_rank <= 10
order by nr_rank
