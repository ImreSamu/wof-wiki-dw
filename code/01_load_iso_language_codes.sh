#!/bin/bash
set -e
set -u

# TODO: check license : https://datahub.io/core/language-codes
rm -f language-codes-3b2_csv.csv
wget http://pkgstore.datahub.io/core/language-codes:language-codes-3b2_csv/data/language-codes-3b2_csv.csv


echo """
    CREATE SCHEMA IF NOT EXISTS  codes;
    DROP TABLE IF EXISTS codes.iso_language_codes;
    CREATE TABLE codes.iso_language_codes(
         alpha3_b text primary key
        ,alpha2   text
        ,english  text
    );

    \copy codes.iso_language_codes FROM '/wof/language-codes-3b2_csv.csv' DELIMITER ',' CSV

    DELETE
      FROM codes.iso_language_codes
      WHERE alpha3_b = 'alpha3-b';

    -- analyze --
    VACUUM ANALYZE codes.iso_language_codes;
    CREATE UNIQUE INDEX  ON codes.iso_language_codes (alpha2);

    -- test --
    SELECT * 
    FROM codes.iso_language_codes 
    LIMIT 12;

    \d+ codes.iso_language_codes;

""" | psql -e 
