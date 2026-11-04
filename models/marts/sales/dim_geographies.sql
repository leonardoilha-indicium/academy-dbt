with
    address as (
        select *
        from {{ ref('stg_address') }}
    )

    , state_province as (
        select *
        from {{ ref('stg_state_province') }}
    )

    , country_region as (
        select *
        from {{ ref('stg_country_region') }}
    )

    , cities as (
        select distinct
            address.nk_state_province
            , address.nm_city
        from address
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['cities.nk_state_province', 'cities.nm_city']) }} as sk_geography
            , cities.nm_city
            , cities.nk_state_province
            , state_province.cd_state_province
            , state_province.nm_state_province
            , state_province.cd_country_region
            , country_region.nm_country_region
        from cities
        inner join state_province
            on cities.nk_state_province = state_province.nk_state_province
        inner join country_region
            on state_province.cd_country_region = country_region.cd_country_region
    )

select *
from final
