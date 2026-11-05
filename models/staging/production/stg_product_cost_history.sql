with
    source as (
        select *
        from {{ source('production', 'productcosthistory') }}
    )

    , renamed as (
        select
            cast(productid as int) as nk_product
            , cast(startdate as date) as dt_start
            , cast(enddate as date) as dt_end
            , cast(standardcost as decimal(19, 4)) as vl_standard_cost
        from source
    )

select *
from renamed
