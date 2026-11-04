with
    source as (
        select *
        from {{ source('person', 'countryregion') }}
    )

    , renamed as (
        select
            trim(countryregioncode) as cd_country_region
            , trim(name) as nm_country_region
        from source
    )

select *
from renamed
