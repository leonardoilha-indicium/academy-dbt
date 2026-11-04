with
    source as (
        select *
        from {{ source('person', 'address') }}
    )

    , renamed as (
        select
            cast(addressid as int) as nk_address
            , cast(stateprovinceid as int) as nk_state_province
            , trim(city) as nm_city
        from source
    )

select *
from renamed
