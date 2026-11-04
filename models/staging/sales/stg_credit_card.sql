with
    source as (
        select *
        from {{ source('sales', 'creditcard') }}
    )

    , renamed as (
        select
            cast(creditcardid as int) as nk_credit_card
            , trim(cardtype) as ds_card_type
        from source
    )

select *
from renamed
