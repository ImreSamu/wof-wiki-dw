

create or replace view wof_extended
as

with 
        disamb as (
            select id, 1 as is_disambiguation
            from wof_disambiguation_report
        ),
        redirected as (
            select id, 1 as is_redirected
            from wof_wd_redirects
        ),        
        extrdist as (
            select id, 1 as is_extreme_distance
            from wof_extreme_distance_report
        )
select 
     wof.id
    ,wof.metatable
    ,case when disamb.is_disambiguation=1       then 'wikidata-ERR-Disambiguation'
          when extrdist.is_extreme_distance=1   then 'wikidata-ERR-Extreme distance>50km'
          when redirected.is_redirected=1       then 'wikidata-ERR-Redirected'          
          when wof.wd_id!=''                    then 'no-wikidataid-yet'
                                                else 'wikidata-maybe ok'
     end as _status     
    ,wof.is_superseded
    ,wof.is_deprecated
    ,wof.properties->>'wof:name'                    as wof_name 
    ,wof.properties->>'wof:country'                 as wof_country
    ,wof.wd_id
    ,wof.properties->>'wof:population'              as wof_population
    ,wof.properties->>'wof:population_rank'         as wof_population_rank     
from wof
  left join disamb      on disamb.id    = wof.id
  left join extrdist    on extrdist.id  = wof.id   
  left join redirected  on redirected.id = wof.id
;


create or replace view wof_extended_meta_status_country_summary
as
select metatable, _status , wof_country, count(*) as N
from wof_extended
group by metatable, _status , wof_country
order by metatable, _status , wof_country
;

create or replace view wof_extended_status_summary
as
select  _status , count(*) as N
from wof_extended
group by _status
order by _status
;