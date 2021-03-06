


CREATE OR REPLACE FUNCTION  adm0countries_clean(name text)
    RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE   AS
$func$
select trim( translate( regexp_replace(  nameclean( name ) ,
 $$[[:<:]](province|island|islands|i.|is.)[[:>:]]$$,
  ' ',
  'gi'
),'  ',' ') );
$func$
;


drop table if exists                    newd.wd_match_admin_0_countries CASCADE;
EXPLAIN ANALYSE CREATE UNLOGGED TABLE   newd.wd_match_admin_0_countries  as
select
     wd_id
    ,wd_label               as wd_name_en
    ,check_number(wd_label) as wd_name_has_num
    ,          (regexp_split_to_array( wd_label , '[,()]'))[1]  as wd_name_en_clean
    ,adm0sub_clean((regexp_split_to_array( wd_label , '[,()]'))[1]) as una_wd_name_en_clean
    ,iscebuano                  as wd_is_cebuano
    ,nSitelinks
    --  ,get_wdc_value(data, 'P1566')      as p1566_geonames
    ,get_wdc_item_label(data,'P31')    as p31_instance_of
    ,get_wdc_item_label(data,'P17')    as p17_country_id
    ,get_wd_name_array(data)           as wd_name_array
    ,get_wd_altname_array(data)        as wd_altname_array
    ,get_wd_concordances(data)         as wd_concordances_array
    ,cartodb.CDB_TransformToWebmercator(geom::geometry)  as wd_point_merc
    ,a_wof_type
from wd.wdx
where  ( (a_wof_type  &&  ARRAY['country','P901','dmz'] )
    and (a_wof_type  @>  ARRAY['hasP625'] )
    and not iscebuano
    and wd_id not in ('Q46879'  -- Baker Island 
                     ,'Q25359'  -- Navassa Island 
                     ,'Q59146'  -- Kyrenia District 
                     ) 
)
    or wd_id  in (
         'Q1257783'    -- Bajo Nuevo Bank 
        ,'Q51'         -- Antarica
        ,'Q1169008'    -- Serranilla Bank
        ,'Q628716'     -- Scarborough Shoal
        ,'Q333946'     -- Siachen Glacier
        ,'Q172216'     -- Coral Sea Islands
        ,'Q26988'      -- Cook Islands 
        ,'Q762570'     -- Guantanamo Bay Naval Base
        ,'Q16645'      -- United States Minor Outlying Islands
        ,'Q116970'     -- United Nations Buffer Zone in Cyprus 
        ,'Q4824275'    -- Australian Indian Ocean Territories
    )

;


CREATE INDEX  ON  newd.wd_match_admin_0_countries USING GIST(wd_point_merc);
CREATE INDEX  ON  newd.wd_match_admin_0_countries (wd_id);
ANALYSE           newd.wd_match_admin_0_countries ;


--
---------------------------------------------------------------------------------------
--

\set neextrafields   ,sovereignt, sov_a3,admin,adm0_a3, geounit, name_long, formal_en,formal_fr, fips_10_ ,iso_a2,iso_a3,un_a3

drop table if exists          newd.ne_match_admin_0_countries CASCADE;
CREATE UNLOGGED TABLE         newd.ne_match_admin_0_countries  as
select
     ne_id
    ,min_zoom
    ,featurecla
    ,name                as ne_name
    ,adm0sub_clean(name)    as ne_una_name
    ,check_number(name)  as ne_name_has_num
    ,ARRAY[name::text,adm0countries_clean(name)::text,adm0countries_clean(name_alt)::text,unaccent(name)::text,unaccent(name_alt)::text]     as ne_name_array
    ,cartodb.CDB_TransformToWebmercator(geometry)   as ne_geom_merc
    ,ST_PointOnSurface(geometry)  as ne_point
    ,wikidataid as ne_wd_id
    :neextrafields
from ne.ne_10m_admin_0_countries
;

CREATE INDEX  ON newd.ne_match_admin_0_countries  USING GIST(ne_geom_merc);
ANALYSE          newd.ne_match_admin_0_countries;

\set wd_input_table           newd.wd_match_admin_0_countries
\set ne_input_table           newd.ne_match_admin_0_countries

\set ne_wd_match               newd.ne_wd_match_admin_0_countries_match
\set ne_wd_match_agg           newd.ne_wd_match_admin_0_countries_match_agg
\set ne_wd_match_agg_sum       newd.ne_wd_match_admin_0_countries_match_agg_sum
\set ne_wd_match_notfound      newd.ne_wd_match_admin_0_countries_match_notfound
\set safedistance    800000
\set searchdistance 1500003
\set suggestiondistance 1100000

\set mcond1     (( ne.ne_una_name = wd.una_wd_name_en_clean ) or (  wd_name_array && ne_name_array ) or (  ne_name_array && wd_altname_array )  or (jarowinkler( ne.ne_una_name, wd.una_wd_name_en_clean)>.971 ) )
\set mcond2  and (ST_DWithin ( wd.wd_point_merc, ne.ne_geom_merc , :searchdistance ))
\set mcond3 

-- find correct ne_id!
-- \set mcond3  or ( (wd.wd_id='''Q4824275''') and (ne.ne_id=106) )or ( (wd.wd_id='''Q51''') and (ne.ne_id=12) ) or ( (wd.wd_id='''Q16645''') and (ne.ne_id=237) ) or ( (wd.wd_id='''Q51''') and (ne.ne_id=12) ) or ( (wd.wd_id='''Q116970''') and (ne.ne_id=47) )

\ir 'template_newd_matching.sql'





