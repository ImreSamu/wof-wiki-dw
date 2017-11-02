


drop table if exists wof_rec;
create table wof_rec as
select 
    id
   ,properties->>'wof:name'                    as wof_name 
   ,properties->'wof:concordances'->>'wd:id'   as wd_id
   ,jsonb_object_keys(properties)              as wof_property
   ,properties->jsonb_object_keys(properties)  as wof_jvalue
   ,jsonb_typeof( properties->jsonb_object_keys(properties) ) as wof_jtype 
from whosonfirst;

create index on wof_rec  ( id );
create index on wof_rec  ( wd_id );
create index on wof_rec  ( wof_property );

analyze wof_rec;






drop table if exists wof_name;
create table wof_name as
select  
      id
    , wof_name
    , wd_id
    , wof_property
    , wof_value 
    , wof_arrayorder
    , jsonb_array_length(wof_rec.wof_jvalue) as wof_arrayorder_max
from wof_rec 
    ,jsonb_array_elements_text(wof_jvalue) with ordinality as a(wof_value,wof_arrayorder)
where wof_jtype='array' and substr(wof_property,1,5)='name:' 
order by id, wof_property, wof_arrayorder
;

create index on wof_name  ( id );
create index on wof_name  ( wd_id );
create index on wof_name  ( wof_property );

analyze wof_name;

