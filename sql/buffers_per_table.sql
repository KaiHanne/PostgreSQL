/*
    file: buffers_per_table.sql
    date: Thu Apr  7 12:05:03 CEST 2016
    what: show the 20 largest tablebuffers

    Dependency: ad pg_buffercache extension to the database.
*/

-- :: argv none, show the 20 largest tablebuffers

/*
    file: buffers_per_table.sql
    date: Thu Apr  7 12:05:03 CEST 2016
    what: show the 20 largest tablebuffers
*/

-- :: argv none, show the 20 largest tablebuffers

DO $$
BEGIN

   IF NOT EXISTS
            ( SELECT 1
              FROM   information_schema.tables
              WHERE  table_schema = 'public'
              AND    table_name = 'pg_buffercache'
            )
   THEN
      RAISE NOTICE 'Extension pg_buffercache not created in this database. Please ignore the error message!';
   ELSE
      RAISE NOTICE 'Show the 20 largest tablebuffers';
   END IF ;
END
$$;

\echo

SELECT c.relname as tablename
,      pg_size_pretty(count(*) * 8192) as buffered
,      round(100.0 * count(*) / ( SELECT setting FROM pg_settings WHERE name='shared_buffers')::integer,1) AS buffers_percent
,      round(100.0 * count(*) * 8192 / pg_relation_size(c.oid),1) AS percent_of_table
FROM   pg_class c
INNER  JOIN pg_buffercache b
ON     b.relfilenode = c.relfilenode
INNER
  JOIN pg_database d
ON   ( b.reldatabase = d.oid
   AND d.datname = current_database())
WHERE  pg_relation_size(c.oid) > 0
GROUP  BY c.oid, c.relname
ORDER  BY 3 DESC
LIMIT  20;
