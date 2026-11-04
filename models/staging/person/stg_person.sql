with
    source as (
        select *
        from {{ source('person', 'person') }}
    )

    , renamed as (
        select
            cast(businessentityid as int) as nk_person
            , trim(firstname) as nm_first
            , trim(middlename) as nm_middle
            , trim(lastname) as nm_last
        from source
    )

select *
from renamed
