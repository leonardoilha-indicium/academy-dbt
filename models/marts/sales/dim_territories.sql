with
    sales_territory as (
        select *
        from {{ ref('stg_sales_territory') }}
    )

    , country_region as (
        select *
        from {{ ref('stg_country_region') }}
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['sales_territory.nk_territory']) }} as sk_territory
            , sales_territory.nk_territory
            , sales_territory.nm_territory
            , sales_territory.nm_territory_group
            , sales_territory.cd_country_region
            , country_region.nm_country_region
        from sales_territory
        inner join country_region
            on sales_territory.cd_country_region = country_region.cd_country_region
    )

select *
from final
