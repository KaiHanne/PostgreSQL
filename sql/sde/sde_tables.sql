/*

   file: sde_tables.sql
         Compare ARGIS table registry with Postgres catalog 
   Date: Fri Apr 23 11:31:40 CEST 2021
 Author: Gert Jan Willems
         RAS/DBB provincie Gelderland

*/

\qecho
\qecho Compare ARGIS table registry with Postgres catalog 
\qecho

WITH   table_registry AS
   (   SELECT sr.schema
       ,      sr.owner
       ,      sr.table_name AS SDE_Table 
       FROM   sde.sde_table_registry sr
       WHERE  sr.schema LIKE :'SCHEMA'
   )
,      catalog_tables AS
   (   SELECT pg.tablename
       ,      pg.schemaname
       ,      pg.tableowner
       FROM   pg_tables pg
       WHERE  pg.schemaname LIKE :'SCHEMA'
   )
SELECT tr.SDE_Table
,      tr.schema AS SDE_Schema
,      tr.owner  AS SDE_Owner
,      ct.tablename AS PG_Table
,      ct.schemaname AS PG_Schema
,      ct.tableowner AS PG_Owner
FROM   table_registry tr
RIGHT OUTER
JOIN   catalog_tables ct
ON     ct.tablename  = tr.SDE_Table
AND    ct.schemaname = tr.schema
AND    ct.tableowner = tr.owner
ORDER  BY 1,3,4
;
