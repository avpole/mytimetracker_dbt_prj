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
        lower(processfilepath) as processfile
	    , '\\' || lower(processfilepath) as processfile_pattern
        , nameapplication
        , typeapplication
        , activity_category
        , activity_type
        , row_number() over (partition by processfilepath order by {{ var("normalized_at_column") }} desc) as row_number
    from {{ source('timetracker', 'apps_analyzed_gptchat') }}
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
        , activity_category
        , activity_type
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
    , ad.activity_category
    , ad.activity_type
from process as p
    left join appdedup as ad on lower(p.processfilepath) like '%' || lower(ad.processfile_pattern) || '%' 