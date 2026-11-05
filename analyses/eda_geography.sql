with
    fact_sales as (
        select
            nk_sales_order
            , fk_geography
            , vl_gross
            , vl_net
        from {{ ref('fact_sales') }}
    )

    , dim_geographies as (
        select
            sk_geography
            , nm_city
            , nm_state_province
            , nm_country_region
        from {{ ref('dim_geographies') }}
    )

    , sales_by_city as (
        select
            dim_geographies.nm_country_region
            , dim_geographies.nm_state_province
            , dim_geographies.nm_city
            , count(distinct fact_sales.nk_sales_order) as qt_orders
            , sum(fact_sales.vl_gross) as vl_gross
            , sum(fact_sales.vl_net) as vl_net
        from fact_sales
        inner join dim_geographies
            on fact_sales.fk_geography = dim_geographies.sk_geography
        group by
            dim_geographies.nm_country_region
            , dim_geographies.nm_state_province
            , dim_geographies.nm_city
    )

    , sales_by_country as (
        select
            'country' as ds_level
            , nm_country_region as ds_member
            , sum(qt_orders) as qt_orders
            , sum(vl_gross) as vl_gross
            , sum(vl_net) as vl_net
        from sales_by_city
        group by nm_country_region
    )

    , ranked_cities as (
        select
            nm_city
            , nm_state_province
            , qt_orders
            , vl_gross
            , vl_net
            , row_number() over (order by vl_gross desc) as nr_rank
        from sales_by_city
    )

    , top_cities as (
        select
            'top 5 city' as ds_level
            , nm_city || ', ' || nm_state_province as ds_member
            , qt_orders
            , vl_gross
            , vl_net
        from ranked_cities
        where nr_rank <= 5
    )

    , unioned as (
        select *
        from sales_by_country

        union all

        select *
        from top_cities
    )

select
    ds_level
    , ds_member
    , qt_orders
    , round(vl_gross, 2) as vl_gross
    , round(vl_net / qt_orders, 2) as vl_net_per_order
from unioned
order by ds_level desc, vl_gross desc
