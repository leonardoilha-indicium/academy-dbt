with
    source as (
        select *
        from {{ source('sales', 'creditcard') }}
    )

    , renamed as (
        select
            cast(creditcardid as int) as credit_card_id
            , trim(cardtype) as card_type
        from source
    )

select *
from renamed
