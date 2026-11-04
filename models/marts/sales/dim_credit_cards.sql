with
    credit_card as (
        select *
        from {{ ref('stg_credit_card') }}
    )

    /* Orders placed without a credit card point to this member */
    , unknown_member as (
        select
            -1 as nk_credit_card
            , 'Unknown' as ds_card_type
    )

    , unioned as (
        select
            nk_credit_card
            , ds_card_type
        from credit_card

        union all

        select
            nk_credit_card
            , ds_card_type
        from unknown_member
    )

    , final as (
        select
            nk_credit_card as sk_credit_card
            , nk_credit_card
            , ds_card_type
        from unioned
    )

select *
from final
