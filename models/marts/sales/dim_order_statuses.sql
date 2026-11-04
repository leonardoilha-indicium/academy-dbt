with
    /* The source has no status lookup table, so the codes are defined here */
    statuses as (
        select
            nk_order_status
            , nm_order_status
        from values
            (1, 'In process')
            , (2, 'Approved')
            , (3, 'Backordered')
            , (4, 'Rejected')
            , (5, 'Shipped')
            , (6, 'Cancelled')
            as statuses(nk_order_status, nm_order_status)
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['nk_order_status']) }} as sk_order_status
            , nk_order_status
            , nm_order_status
        from statuses
    )

select *
from final
