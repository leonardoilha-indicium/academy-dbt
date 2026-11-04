with
    source as (
        select *
        from {{ source('production', 'productcategory') }}
    )

    , renamed as (
        select
            cast(productcategoryid as int) as nk_product_category
            , trim(name) as nm_product_category
        from source
    )

select *
from renamed
