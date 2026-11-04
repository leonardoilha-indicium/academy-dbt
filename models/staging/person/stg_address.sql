with
    source as (
        select *
        from {{ source('person', 'address') }}
    )

    , renamed as (
        select
            cast(addressid as int) as address_id
            , cast(stateprovinceid as int) as state_province_id
            , trim(city) as city_name
        from source
    )

select *
from renamed
