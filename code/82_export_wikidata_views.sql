
\cd :reportdir
\copy (select * from wikidata.wd_names_preferred) TO 'wikidata_wd_names_preferred.csv' CSV  HEADER;
\copy (select * from wikidata.wd_sitelinks)       TO 'wikidata_wd_sitelinks.csv'       CSV  HEADER;
\copy (select * from wikidata.wd_descriptions)    TO 'wikidata_wd_descriptions.csv'    CSV  HEADER;
\copy (select * from wikidata.wd_aliases)         TO 'wikidata_wd_aliases'             CSV  HEADER;
\copy (select * from wikidata.wd_labels)          TO 'wikidata_wd_labels.csv'          CSV  HEADER;
