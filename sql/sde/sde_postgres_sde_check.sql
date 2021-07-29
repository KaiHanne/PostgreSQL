/*

   file: sde_postgres_sde_check.sql
         check missing objects in Postgres database whish are in sde.sde_table_registry
   Date: Tue Mar 30 16:50:59 CEST 2021

 Author: Gert J. Willems AKA (github.com/)KaiHanne

*/

-- :: argv none, SDE enabled tables missing in Postgres DB present in SDE.SDE_TABLE_REGISTRY

\qecho 

START TRANSACTION;
DO $$
DECLARE
    _query      text;
    _cursor     CONSTANT refcursor := '_cursor';
    _cflg       integer := 0;
BEGIN
   _query :='WITH schema_owner AS
   ( SELECT 
     DISTINCT schema
     ,        owner 
     FROM     sde.sde_table_registry 
   ),
     sde_registry AS
   ( SELECT registration_id
     ,      database_name     
     ,      owner            
     ,      schema          
     ,      table_name     
     ,      registration_date 
     FROM   sde.sde_table_registry 
   )  
SELECT so.schema
,      so.owner
,      sr.table_name
,      sr.database_name
,      sr.registration_date
FROM   schema_owner so
JOIN   sde_registry sr
ON     sr.schema = so.schema
AND    sr.owner = so.owner
WHERE  sr.table_name NOT IN
     ( SELECT tablename 
       FROM   pg_tables 
       WHERE  schemaname = so.schema 
       AND    tableowner = so.owner );';

   IF EXISTS
            ( SELECT 1
              FROM   information_schema.tables
              WHERE  table_schema = 'sde'
              AND    table_name = 'sde_table_registry'
            )
   THEN
      OPEN _cursor FOR EXECUTE _query;
      _cflg := 1;
      RAISE NOTICE 'Find tables which are missing in the Postgres database but present in SDE.SDE_COLUMN_REGISTRY';
   ELSE
      RAISE NOTICE 'SDE not available in this database. Please ignore the _cursor error message!';
   END IF ;
END
$$ ;


FETCH ALL FROM _cursor;
CLOSE _cursor;
COMMIT;
/* ======== end of arcgis_postgres_sde_check.sql ======== */
