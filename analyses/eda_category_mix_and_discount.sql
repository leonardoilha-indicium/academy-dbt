with
    fact_sales as (
        select
            nk_sales_order
            , fk_product
            , qt_order
            , vl_gross
            , vl_discount
        from {{ ref('fact_sales') }}
    )

    , dim_products as (
        select
            sk_product
            , nm_product_category
        from {{ ref('dim_products') }}
    )

    , sales_by_category as (
        select
            dim_products.nm_product_category
            , count(distinct fact_sales.nk_sales_order) as qt_orders
            , sum(fact_sales.qt_order) as qt_units
            , sum(fact_sales.vl_gross) as vl_gross
            , sum(fact_sales.vl_discount) as vl_discount
        from fact_sales
        inner join dim_products
            on fact_sales.fk_product = dim_products.sk_product
        group by dim_products.nm_product_category
    )

select
    nm_product_category
    , qt_orders
    , qt_units
    , round(vl_gross, 2) as vl_gross
    , round(vl_gross / sum(vl_gross) over (), 4) as pc_gross_share
    , round(vl_discount / vl_gross, 4) as pc_discount_rate
from sales_by_category
order by vl_gross desc
