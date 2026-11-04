with
    source as (
        select *
        from {{ source('person', 'stateprovince') }}
    )

    , renamed as (
        select
            cast(stateprovinceid as int) as state_province_id
            , trim(stateprovincecode) as state_province_code
            , trim(countryregioncode) as country_region_code
            , trim(name) as state_province_name
        from source
    )

select *
from renamed
