with
    quota as (
        select *
        from {{ ref('stg_sales_person_quota_history') }}
    )

    , fact_orders as (
        select
            nk_sales_order
            , fk_sales_person
            , dt_order
            , vl_subtotal
        from {{ ref('fact_orders') }}
    )

    , dim_salespersons as (
        select
            sk_sales_person
            , nk_sales_person
        from {{ ref('dim_salespersons') }}
    )

    , dim_dates as (
        select
            sk_date
            , dt_calendar
        from {{ ref('dim_dates') }}
    )

    , last_order as (
        select max(dt_order) as dt_last_order
        from fact_orders
    )

    , quota_periods as (
        select
            quota.nk_sales_person
            , quota.dt_quota as dt_quota_start
            , coalesce(
                date_sub(
                    lead(quota.dt_quota) over (
                        partition by quota.nk_sales_person
                        order by quota.dt_quota
                    )
                    , 1
                )
                , last_order.dt_last_order
            ) as dt_quota_end
            , quota.vl_sales_quota
        from quota
        cross join last_order
    )

    , sales_in_period as (
        select
            dim_salespersons.sk_sales_person as fk_sales_person
            , quota_periods.nk_sales_person
            , quota_periods.dt_quota_start
            , quota_periods.dt_quota_end
            , quota_periods.vl_sales_quota
            , count(distinct fact_orders.nk_sales_order) as qt_orders
            , coalesce(sum(fact_orders.vl_subtotal), 0) as vl_net_sales
        from quota_periods
        inner join dim_salespersons
            on quota_periods.nk_sales_person = dim_salespersons.nk_sales_person
        left join fact_orders
            on dim_salespersons.sk_sales_person = fact_orders.fk_sales_person
            and fact_orders.dt_order between quota_periods.dt_quota_start and quota_periods.dt_quota_end
        group by
            dim_salespersons.sk_sales_person
            , quota_periods.nk_sales_person
            , quota_periods.dt_quota_start
            , quota_periods.dt_quota_end
            , quota_periods.vl_sales_quota
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['sales_in_period.nk_sales_person', 'sales_in_period.dt_quota_start']) }} as sk_sales_quota
            , sales_in_period.fk_sales_person
            , dim_quota_start_dates.sk_date as fk_quota_start_date
            , dim_quota_end_dates.sk_date as fk_quota_end_date
            , sales_in_period.dt_quota_start
            , sales_in_period.dt_quota_end
            , sales_in_period.vl_sales_quota
            , sales_in_period.qt_orders
            , cast(sales_in_period.vl_net_sales as decimal(19, 4)) as vl_net_sales
        from sales_in_period
        inner join dim_dates as dim_quota_start_dates
            on sales_in_period.dt_quota_start = dim_quota_start_dates.dt_calendar
        inner join dim_dates as dim_quota_end_dates
            on sales_in_period.dt_quota_end = dim_quota_end_dates.dt_calendar
    )

select *
from final
