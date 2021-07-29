/*
     File: sde_health_check.sql
     Date: Wed Mar 31 10:30:25 CEST 2021

   Author: Gert J. Willems AKA (github.com/)KaiHanne

*/

-- :: argv none, wrapper for 3 argis check queries
\t
\a
SELECT 'ArcGIS Health check on '|| current_database() || ' @ '|| current_timestamp;

\t
\a

\i arcgis_table_column.sql
\i arcgis_column_table.sql
\i arcgis_postgres_sde_check.sql
