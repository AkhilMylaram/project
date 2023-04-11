#!/bin/sh

. ./rdbms_creds.py

CONNECT_STRING="${rdbms_username}/${rdbms_password}${rdbms_database}"

for TABLE_NAME in EBS_DMCR EBS_DMCR_OBJECT EBS_DMCR_PRODUCT EBS_DMCR_TEXT EBS_FAMILY EBS_FCR EBS_FCR_FT_ITEM_LINE EBS_FCR_PRODUCT EBS_FCR_PROD_FILETYPE EBS_FCR_PROD_FT_ITEM EBS_FCR_SRC EBS_PRODUCT EBS_SDCR EBS_SDCR_ITEM_LINE EBS_SDCR_PRODUCT EBS_SDCR_PROD_DATATYPE EBS_SDCR_PROD_DT_ITEM EBS_SDCR_SRC EBS_VERSION
do
    echo $TABLE_NAME
    sqlplus $CONNECT_STRING <<ENDSQL
SET SERVEROUTPUT ON
exec dbms_output.enable(1000000);
DECLARE
  v_table_name VARCHAR2(1000);
  v_sql        VARCHAR2(1000);
  v_max_id     NUMBER;
  v_max_seq    NUMBER;
  v_seq_cnt    NUMBER;
  v_nextval    NUMBER;
BEGIN
  v_table_name := '${TABLE_NAME}';
  dbms_output.put_line(' ');
  dbms_output.put_line('TABLE: ' || v_table_name);
  v_sql := 'SELECT MAX(id) FROM ' || v_table_name;
  dbms_output.put_line(v_sql);
  EXECUTE IMMEDIATE v_sql INTO v_max_id;
  dbms_output.put_line('max_id: ' || TO_CHAR(v_max_id));
  v_sql := 'SELECT ' || v_table_name || '_seq.nextval FROM dual';
  EXECUTE IMMEDIATE v_sql INTO v_max_seq;
  dbms_output.put_line('max_seq: ' || TO_CHAR(v_max_seq));
  IF ( v_max_seq < v_max_id ) THEN
      dbms_output.put_line('Sequence too low');
      dbms_output.put_line('Need to correct');
      v_nextval := 0;
      FOR v_seq_cnt IN v_max_seq..v_max_id
          LOOP
             v_sql := 'SELECT ' || v_table_name || '_seq.nextval FROM dual';
             EXECUTE IMMEDIATE v_sql INTO v_nextval;
          END LOOP;
      dbms_output.put_line('  New Sequence Value: ' || TO_CHAR(v_nextval));
  END IF;
  dbms_output.put_line(v_sql);
END;
/
ENDSQL
done
