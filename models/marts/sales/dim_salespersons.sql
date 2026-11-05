with
    sales_person as (
        select *
        from {{ ref('stg_sales_person') }}
    )

    , person as (
        select *
        from {{ ref('stg_person') }}
    )

    , salespersons as (
        select
            sales_person.nk_sales_person
            , person.nm_first || ' ' || person.nm_last as nm_sales_person
            , sales_person.nk_territory
        from sales_person
        inner join person
            on sales_person.nk_sales_person = person.nk_person
    )

    , unknown_member as (
        select
            -1 as nk_sales_person
            , 'No salesperson' as nm_sales_person
            , cast(null as int) as nk_territory
    )

    , unioned as (
        select
            nk_sales_person
            , nm_sales_person
            , nk_territory
        from salespersons

        union all

        select
            nk_sales_person
            , nm_sales_person
            , nk_territory
        from unknown_member
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['nk_sales_person']) }} as sk_sales_person
            , nk_sales_person
            , nm_sales_person
            , nk_territory
        from unioned
    )

select *
from final
