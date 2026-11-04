with
    date_spine as (
        {{
            dbt_utils.date_spine(
                datepart="day"
                , start_date="cast('2011-01-01' as date)"
                , end_date="cast('2015-01-01' as date)"
            )
        }}
    )

    , dates as (
        select cast(date_day as date) as dt_calendar
        from date_spine
    )

    , final as (
        select
            dt_calendar as sk_date
            , dt_calendar
            , year(dt_calendar) as nr_year
            , quarter(dt_calendar) as nr_quarter
            , month(dt_calendar) as nr_month
            , date_format(dt_calendar, 'MMMM') as nm_month
            , date_format(dt_calendar, 'yyyy-MM') as ds_year_month
            , day(dt_calendar) as nr_day_of_month
            , weekday(dt_calendar) + 1 as nr_day_of_week
            , date_format(dt_calendar, 'EEEE') as nm_day_of_week
            , weekday(dt_calendar) >= 5 as is_weekend
        from dates
    )

select *
from final
