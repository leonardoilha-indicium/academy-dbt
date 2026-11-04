with
    source as (
        select *
        from {{ source('production', 'productsubcategory') }}
    )

    , renamed as (
        select
            cast(productsubcategoryid as int) as nk_product_subcategory
            , cast(productcategoryid as int) as nk_product_category
            , trim(name) as nm_product_subcategory
        from source
    )

select *
from renamed
