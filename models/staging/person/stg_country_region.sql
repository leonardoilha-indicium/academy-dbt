with
    source as (
        select *
        from {{ source('person', 'countryregion') }}
    )

    , renamed as (
        select
            trim(countryregioncode) as country_region_code
            , trim(name) as country_region_name
        from source
    )

select *
from renamed
