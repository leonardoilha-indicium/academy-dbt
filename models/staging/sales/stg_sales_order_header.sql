with
    source as (
        select *
        from {{ source('sales', 'salesorderheader') }}
    )

    , renamed as (
        select
            cast(salesorderid as int) as nk_sales_order
            , cast(customerid as int) as nk_customer
            , cast(salespersonid as int) as nk_sales_person
            , cast(territoryid as int) as nk_territory
            , cast(billtoaddressid as int) as nk_bill_to_address
            , cast(shiptoaddressid as int) as nk_ship_to_address
            , cast(shipmethodid as int) as nk_ship_method
            , cast(creditcardid as int) as nk_credit_card
            , cast(orderdate as date) as dt_order
            , cast(duedate as date) as dt_due
            , cast(shipdate as date) as dt_ship
            , cast(status as int) as nk_order_status
            , cast(onlineorderflag as boolean) as is_online_order
            , cast(subtotal as decimal(19, 4)) as vl_subtotal
            , cast(taxamt as decimal(19, 4)) as vl_tax
            , cast(freight as decimal(19, 4)) as vl_freight
            , cast(totaldue as decimal(19, 4)) as vl_total_due
        from source
    )

select *
from renamed
