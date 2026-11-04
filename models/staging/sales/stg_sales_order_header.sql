with
    source as (
        select *
        from {{ source('sales', 'salesorderheader') }}
    )

    , renamed as (
        select
            cast(salesorderid as int) as sales_order_id
            , cast(customerid as int) as customer_id
            , cast(territoryid as int) as territory_id
            , cast(billtoaddressid as int) as bill_to_address_id
            , cast(shiptoaddressid as int) as ship_to_address_id
            , cast(creditcardid as int) as credit_card_id
            , cast(orderdate as date) as order_date
            , cast(status as int) as order_status
            , cast(onlineorderflag as boolean) as is_online_order
            , cast(subtotal as decimal(19, 4)) as subtotal_amount
            , cast(taxamt as decimal(19, 4)) as tax_amount
            , cast(freight as decimal(19, 4)) as freight_amount
            , cast(totaldue as decimal(19, 4)) as total_due_amount
        from source
    )

select *
from renamed
