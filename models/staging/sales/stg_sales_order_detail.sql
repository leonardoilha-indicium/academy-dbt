with
    source as (
        select *
        from {{ source('sales', 'salesorderdetail') }}
    )

    , renamed as (
        select
            cast(salesorderdetailid as int) as sales_order_detail_id
            , cast(salesorderid as int) as sales_order_id
            , cast(productid as int) as product_id
            , cast(specialofferid as int) as special_offer_id
            , cast(orderqty as int) as order_qty
            , cast(unitprice as decimal(19, 4)) as unit_price
            , cast(unitpricediscount as decimal(19, 4)) as unit_price_discount
        from source
    )

select *
from renamed
