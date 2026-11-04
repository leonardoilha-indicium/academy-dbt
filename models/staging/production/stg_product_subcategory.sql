with
    source as (
        select *
        from {{ source('production', 'productsubcategory') }}
    )

    , renamed as (
        select
            cast(productsubcategoryid as int) as product_subcategory_id
            , cast(productcategoryid as int) as product_category_id
            , trim(name) as product_subcategory_name
        from source
    )

select *
from renamed
