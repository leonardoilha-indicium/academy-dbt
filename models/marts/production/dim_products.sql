with
    product as (
        select *
        from {{ ref('stg_product') }}
    )

    , product_subcategory as (
        select *
        from {{ ref('stg_product_subcategory') }}
    )

    , product_category as (
        select *
        from {{ ref('stg_product_category') }}
    )

    , final as (
        select
            product.nk_product as sk_product
            , product.nk_product
            , product.nm_product
            , product.cd_product
            , coalesce(product.ds_color, 'Not defined') as ds_color
            , product.vl_list_price
            , product.vl_standard_cost
            , coalesce(
                product_subcategory.nm_product_subcategory
                , 'Not defined'
            ) as nm_product_subcategory
            , coalesce(
                product_category.nm_product_category
                , 'Not defined'
            ) as nm_product_category
        from product
        left join product_subcategory
            on product.nk_product_subcategory = product_subcategory.nk_product_subcategory
        left join product_category
            on product_subcategory.nk_product_category = product_category.nk_product_category
    )

select *
from final
