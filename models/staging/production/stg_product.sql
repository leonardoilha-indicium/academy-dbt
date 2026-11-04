with
    source as (
        select *
        from {{ source('production', 'product') }}
    )

    , renamed as (
        select
            cast(productid as int) as nk_product
            , cast(productsubcategoryid as int) as nk_product_subcategory
            , trim(name) as nm_product
            , trim(productnumber) as cd_product
            , trim(color) as ds_color
            , cast(standardcost as decimal(19, 4)) as vl_standard_cost
            , cast(listprice as decimal(19, 4)) as vl_list_price
        from source
    )

select *
from renamed
