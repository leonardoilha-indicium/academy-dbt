with
    ship_method as (
        select *
        from {{ ref('stg_ship_method') }}
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['nk_ship_method']) }} as sk_ship_method
            , nk_ship_method
            , nm_ship_method
            , vl_ship_base
            , vl_ship_rate
        from ship_method
    )

select *
from final
