with
    customer as (
        select *
        from {{ ref('stg_customer') }}
    )

    , person as (
        select *
        from {{ ref('stg_person') }}
    )

    , store as (
        select *
        from {{ ref('stg_store') }}
    )

    , person_names as (
        select
            person.nk_person
            , person.nm_first
                || coalesce(' ' || person.nm_middle, '')
                || ' ' || person.nm_last as nm_person_full
        from person
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['customer.nk_customer']) }} as sk_customer
            , customer.nk_customer
            , case
                when store.nk_store is not null then 'Store'
                else 'Person'
            end as ds_customer_type
            , case
                when store.nk_store is not null then store.nm_store
                else person_names.nm_person_full
            end as nm_customer
            , case
                when store.nk_store is not null then person_names.nm_person_full
            end as nm_contact
            , customer.nk_territory
        from customer
        left join store
            on customer.nk_store = store.nk_store
        left join person_names
            on customer.nk_person = person_names.nk_person
    )

select *
from final
