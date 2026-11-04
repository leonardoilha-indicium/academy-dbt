with
    source as (
        select *
        from {{ source('person', 'person') }}
    )

    , renamed as (
        select
            cast(businessentityid as int) as person_id
            , trim(firstname) as first_name
            , trim(middlename) as middle_name
            , trim(lastname) as last_name
        from source
    )

select *
from renamed
