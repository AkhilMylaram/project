#!/bin/sh

. ./rdbms_creds.py

CONNECT_STRING="${rdbms_username}/${rdbms_password}${rdbms_database}"

sqlplus $CONNECT_STRING <<ENDSQL
SET SERVEROUTPUT ON
exec dbms_output.enable(1000000);
DROP TABLE ebs_dmcr_dn_object_text;
DROP TABLE ebs_dmcr_dn_object;
DROP TABLE ebs_fcr_dn_item_line;
DROP TABLE ebs_fcr_dn_item;
DROP TABLE ebs_sdcr_dn_item_line;
DROP TABLE ebs_sdcr_dn_item;
@schema-dn-views.ddl
@schema-dn-tables.ddl
SPOOL test_import.log
SET ECHO ON
@export_dn_commit.sql
@export_dn_text_commit.sql
SPOOL OFF
@schema-dn-indexes-pk.ddl
QUIT
ENDSQL
