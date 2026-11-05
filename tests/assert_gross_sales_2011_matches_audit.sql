/*
    Fails when the 2011 gross sales in fact_sales differ from the audited
    value reported by the CEO (12,646,112.16) by more than 0.01.
    Gross sales = sum(unit price * quantity) at order line grain, before discounts.
*/
with
    fact_sales as (
        select
            fk_order_date
            , vl_gross
        from {{ ref('fact_sales') }}
    )

    , dim_dates as (
        select
            sk_date
            , nr_year
        from {{ ref('dim_dates') }}
    )

    , gross_sales_2011 as (
        select sum(fact_sales.vl_gross) as vl_gross_2011
        from fact_sales
        inner join dim_dates
            on fact_sales.fk_order_date = dim_dates.sk_date
        where dim_dates.nr_year = 2011
    )

select vl_gross_2011
from gross_sales_2011
where abs(vl_gross_2011 - 12646112.16) > 0.01
