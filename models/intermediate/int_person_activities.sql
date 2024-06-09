{{
    config (
      materialized='view'
    )
}}

select
    ssd.st_id as activity_id
    , ssd.username
    , ssd.pcname
	, ssd.systemstatus
    , ssd.tracktime
    , ssd.processfilename
    , ssd.processfilepath
    , ssd.activewindowtitle
    , ssd.workspaceid
    , ssd.activity_interval
    , ssd.sid_person

    , pers.fullname as personname

    , apps.nameapplication
    , apps.typeapplication
    , apps.app_id

    , spg.personalgroupid
    , pg."Name" as persongroupname

from {{ ref('stg_singletracks_dedup') }} as ssd
    left join {{ source('timetracker', 'peoplematchingmodels') }} as pers
        on ssd.sid_person = pers.sid and ssd.workspaceid = pers.workspaceid
    left join {{ ref('stg_applications_by_processfilepath') }} as apps
        on lower(ssd.processfilepath) = lower(apps.processfilepath)
    left join {{ source('timetracker', 'sidpersonalgroups') }} spg
        on ssd.sid_person = spg.sid
    left join {{ source('timetracker', 'personalgroups') }} pg
        on spg.personalgroupid = pg."Id"