{{
    config (
      materialized='incremental'
      , unique_key='st_id'
      , enabled=True
    )
}}

with stg_singletracks_dedup as (
    select
        "Id" as st_id
        , tracktime 
        ,
            case
                when systemstatus = 1 then 'active'
                when systemstatus = 2 then 'idle'
            end
            as systemstatus
        , username
        , pcname
        , lower(processfilename) as processfilename
        , lower(processfilepath) as processfilepath
        , activewindowtitle
        , workspaceid
        , "Interval" as activity_interval
        , "sid" as sid_person
        , row_number() over (partition by "Id" order by {{ var("normalized_at_column") }}) as rowrank
        , {{ var("normalized_at_column") }} as loadtimestamp
    from {{ source('timetracker', 'singletracks') }}

    {% if is_incremental() %}

    where
        {{ var("normalized_at_column") }} > (select MAX(std.loadtimestamp) FROM {{ this }} std)

    {% endif %}
)

select
    *
from stg_singletracks_dedup
where rowrank = 1
