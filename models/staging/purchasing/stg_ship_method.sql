with
    source as (
        select *
        from {{ source('purchasing', 'shipmethod') }}
    )

    , renamed as (
        select
            cast(shipmethodid as int) as nk_ship_method
            , trim(name) as nm_ship_method
            , cast(shipbase as decimal(19, 4)) as vl_ship_base
            , cast(shiprate as decimal(19, 4)) as vl_ship_rate
        from source
    )

select *
from renamed
