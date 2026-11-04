with
    source as (
        select *
        from {{ source('person', 'stateprovince') }}
    )

    , renamed as (
        select
            cast(stateprovinceid as int) as nk_state_province
            , trim(stateprovincecode) as cd_state_province
            , trim(countryregioncode) as cd_country_region
            , trim(name) as nm_state_province
        from source
    )

select *
from renamed
