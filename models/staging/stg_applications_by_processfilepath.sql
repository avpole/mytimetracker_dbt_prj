{{
    config (
      enabled=True
    )
}}

with process as (
    select distinct
        lower(st.processfilepath) as processfilepath
    from {{ source('timetracker', 'singletracks') }} as st
    where st.processfilepath is not null and length(st.processfilepath) > 0
)
, apps as (
    select distinct
        lower(processfile) as processfile
	    , '\\' || lower(processfile) as processfile_pattern
        , nameapplication
        , typeapplication
        , row_number() over (partition by processfile order by nameapplication) as row_number
    from {{ source('timetracker', 'applicationmatchingmodels') }}
)
, appdedup as (
    select 
        {{ dbt_utils.generate_surrogate_key([
            'processfile'
            , 'nameapplication'
            , 'typeapplication'
        ]) }} as app_id
        , processfile
        , processfile_pattern
        , nameapplication
        , typeapplication
    from apps
    where row_number = 1
)

select
    ad.app_id
    , ad.processfile
    , ad.processfile_pattern
    , ad.nameapplication
    , ad.typeapplication
    , p.processfilepath
from process as p
    left join appdedup as ad on lower(p.processfilepath) like '%' || lower(ad.processfile_pattern) || '%' 