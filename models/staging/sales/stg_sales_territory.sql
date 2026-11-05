with
    source as (
        select *
        from {{ source('sales', 'salesterritory') }}
    )

    , renamed as (
        select
            cast(territoryid as int) as nk_territory
            , trim(name) as nm_territory
            , trim(countryregioncode) as cd_country_region
            , trim(`group`) as nm_territory_group
        from source
    )

select *
from renamed
