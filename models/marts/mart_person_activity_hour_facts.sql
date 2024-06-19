{{
  config (
    materialized = 'incremental'
    , incremental_strategy = 'delete+insert'
    , unique_key = 'activity_id'
  )
}}


with pahf as (
  select
      date_trunc('hour', tracktime) as activity_hour
      , personname
      , username
      , pcname
      , systemstatus
      , workspaceid
      , nameapplication
      , typeapplication
      , activity_category
      , activity_type
      , persongroupname
      , count(*) as activity_count
      , sum(activity_interval) as activity_seconds_sum
      , round(sum(activity_interval)/60) as activity_minutes_sum
  from {{ ref('int_person_activities') }}
  
  {% if is_incremental() %}
  
  where 
    date_trunc('hour', tracktime) >= (select max(activity_hour) from {{ this }}) - interval '1 hour'
  
  {% endif %}

  group by
      activity_hour
      , personname
      , username
      , pcname
      , systemstatus
      , workspaceid
      , nameapplication
      , typeapplication
      , activity_category
      , activity_type
      , persongroupname
)
, pahf_with_key as (
  select {{ dbt_utils.generate_surrogate_key([
            'activity_hour'
            , 'personname'
            , 'username'
            , 'pcname'
            , 'systemstatus'
            , 'workspaceid'
            , 'nameapplication'
            , 'typeapplication'
            , 'activity_category'
            , 'activity_type'
            , 'persongroupname'
      ]) }} as activity_id
      , *
  from pahf
)

select * from pahf_with_key