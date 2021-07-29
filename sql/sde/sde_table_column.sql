/*

   file: sde_table_column.sql
         Find missing tables in the SDE.SDE_TABLE_REGISTRY table which are in SDE.SDE_COLUMN_GEOMETRY table
   Date: Tue Mar 30 16:50:59 CEST 2021

 Author: Gert J. Willems AKA (github.com/)KaiHanne

*/

-- :: argv none, tables missing in SDE.SDE_TABLE_REGISTRY 

\set ON_ERROR_STOP on

START TRANSACTION;
DO $$
DECLARE
    _query      text;
    _cursor     CONSTANT refcursor := '_cursor';
    _cflg       integer := 0;
BEGIN

   _query='WITH schema_owner AS
   ( SELECT 
     DISTINCT schema
     ,        database_name 
     FROM     sde.sde_table_registry 
   ),
     sde_col_registry AS
   (
     SELECT database_name 
     ,      table_name
     ,      schema   
     ,      column_name  
     FROM   sde.sde_column_registry 
   )
   SELECT cr.schema
   ,      cr.table_name
   ,      cr.database_name
   ,      cr.column_name
   FROM   schema_owner so
   JOIN   sde_col_registry cr
   ON     cr.schema = so.schema
   AND    cr.database_name = so.database_name
   WHERE  cr.table_name NOT IN
     ( SELECT table_name 
       FROM   sde.sde_table_registry 
       WHERE  schema = cr.schema 
       AND    database_name = cr.database_name );' ;

   IF EXISTS
            ( SELECT 1
              FROM   information_schema.tables 
              WHERE  table_schema = 'sde'
              AND    table_name = 'sde_table_registry'
            )
   THEN
      OPEN _cursor FOR EXECUTE _query;
      _cflg := 1;
      RAISE NOTICE 'Find tables which are missing in SDE.SDE_TABLE_REGISTRY but present in SDE.SDE_COLUMN_GEOMETRY'; 
   ELSE
      RAISE NOTICE 'SDE not available in this database. Please ignore the _cursor error message!';
   END IF ;
END
$$ ;


FETCH ALL FROM _cursor;
CLOSE _cursor;
COMMIT;

