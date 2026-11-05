with
    customer_sales as (
        select
            nk_customer
            , sum(vl_gross) as vl_gross
        from {{ ref('fact_sales') }}
        group by nk_customer
    )

    , ranked_customers as (
        select
            nk_customer
            , vl_gross
            , row_number() over (order by vl_gross desc, nk_customer) as nr_rank
        from customer_sales
    )

    , customer_bands as (
        select
            case
                when nr_rank <= 10 then '1. top 10'
                when nr_rank <= 100 then '2. top 11 to 100'
                else '3. all other customers'
            end as ds_band
            , vl_gross
        from ranked_customers
    )

select
    ds_band
    , count(*) as qt_customers
    , round(sum(vl_gross), 2) as vl_gross
    , round(sum(vl_gross) / sum(sum(vl_gross)) over (), 4) as pc_gross_share
from customer_bands
group by ds_band
order by ds_band
