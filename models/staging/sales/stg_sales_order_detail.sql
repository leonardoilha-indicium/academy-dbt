with
    source as (
        select *
        from {{ source('sales', 'salesorderdetail') }}
    )

    , renamed as (
        select
            cast(salesorderdetailid as int) as nk_sales_order_detail
            , cast(salesorderid as int) as nk_sales_order
            , cast(productid as int) as nk_product
            , cast(specialofferid as int) as nk_special_offer
            , cast(orderqty as int) as qt_order
            , cast(unitprice as decimal(19, 4)) as vl_unit_price
            , cast(unitpricediscount as decimal(19, 4)) as pc_unit_price_discount
        from source
    )

select *
from renamed
