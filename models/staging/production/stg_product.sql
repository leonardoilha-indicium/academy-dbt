with
    source as (
        select *
        from {{ source('production', 'product') }}
    )

    , renamed as (
        select
            cast(productid as int) as product_id
            , cast(productsubcategoryid as int) as product_subcategory_id
            , trim(name) as product_name
            , trim(productnumber) as product_number
            , trim(color) as color
            , cast(standardcost as decimal(19, 4)) as standard_cost
            , cast(listprice as decimal(19, 4)) as list_price
        from source
    )

select *
from renamed
