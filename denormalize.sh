#!/bin/sh

if [ $# -ne 2 ]
then
    echo "usage: $0 [Source EBS version] [Target EBS Version]"
    exit 1
fi

SRC_EBS_VERSION=$1
TRG_EBS_VERSION=$2
. ./rdbms_creds.py

CONNECT_STRING="${rdbms_username}/${rdbms_password}${rdbms_database}"
TSTAMP=`date "+%Y.%m%d.%H%M"`
LOGFILE=denormalize.${SRC_EBS_VERSION}.${TRG_EBS_VERSION}.${TSTAMP}.log

(
date;
sqlplus $CONNECT_STRING <<ENDSQL
SET SERVEROUTPUT ON
exec dbms_output.enable(1000000);
SET ECHO ON
SET TERMOUT ON
DROP TABLE ebs_dmcr_dn_object_text;
DROP TABLE ebs_dmcr_dn_object;
DROP TABLE ebs_fcr_dn_item_line;
DROP TABLE ebs_fcr_dn_item;
DROP TABLE ebs_sdcr_dn_item_line;
DROP TABLE ebs_sdcr_dn_item;
@schema-dn-views.ddl
@schema-dn-tables.ddl
INSERT INTO ebs_dmcr_dn_object
     SELECT * 
       FROM ebs_dmcr_object_v 
      WHERE trg_ebs_version='${TRG_EBS_VERSION}' and src_ebs_version='${SRC_EBS_VERSION}';
COMMIT;
DECLARE
  CURSOR c1 IS
    SELECT id
      FROM ebs_dmcr_dn_object;
  c1r c1%ROWTYPE;
  row_cnt INTEGER;
BEGIN
  row_cnt := 0;
  OPEN c1;
  LOOP
    FETCH c1 INTO c1r;
    EXIT WHEN c1%NOTFOUND;
    INSERT INTO ebs_dmcr_dn_object_text(
                id, ebs_dmcr_dn_object_id, trg_text, src_text)
         SELECT id, ebs_dmcr_object_id,    trg_text, src_text
           FROM ebs_dmcr_text
          WHERE ebs_dmcr_object_id = c1r.id;
    row_cnt := row_cnt + 1;
    IF ( MOD(row_cnt, 1000) = 0 )
    THEN
      dbms_output.put_line('Row: ' || TO_CHAR(row_cnt));
      COMMIT;
    END IF;
  END LOOP;
  CLOSE c1;
  dbms_output.put_line('Row: ' || TO_CHAR(row_cnt));
  COMMIT;
END;
/
INSERT INTO ebs_fcr_dn_item  
     SELECT *
       FROM ebs_fcr_item_v
      WHERE trg_ebs_version='${TRG_EBS_VERSION}' and src_ebs_version='${SRC_EBS_VERSION}';
COMMIT;
DECLARE
  CURSOR c1 IS
    SELECT id
      FROM ebs_fcr_dn_item;
  c1r c1%ROWTYPE;
  row_cnt INTEGER;
BEGIN
  row_cnt := 0;
  OPEN c1;
  LOOP
    FETCH c1 INTO c1r;
    EXIT WHEN c1%NOTFOUND;
    INSERT INTO ebs_fcr_dn_item_line(
                id, ebs_fcr_dn_item_id,      line_no, trg_line_no, trg_status, trg_text, src_line_no, src_status, src_text)
         SELECT id, ebs_fcr_prod_ft_item_id, line_no, trg_line_no, trg_status, trg_text, src_line_no, src_status, src_text
           FROM ebs_fcr_ft_item_line
          WHERE ebs_fcr_prod_ft_item_id = c1r.id;
    row_cnt := row_cnt + 1;
    IF ( MOD(row_cnt, 1000) = 0 )
    THEN
      dbms_output.put_line('Row: ' || TO_CHAR(row_cnt));
      COMMIT;
    END IF;
  END LOOP;
  CLOSE c1;
  dbms_output.put_line('Row: ' || TO_CHAR(row_cnt));
  COMMIT;
END;
/
INSERT INTO ebs_sdcr_dn_item
     SELECT * 
       FROM ebs_sdcr_item_v
      WHERE trg_ebs_version='${TRG_EBS_VERSION}' and src_ebs_version='${SRC_EBS_VERSION}';
COMMIT;
DECLARE
  CURSOR c1 IS
    SELECT id
      FROM ebs_sdcr_dn_item;
  c1r c1%ROWTYPE;
  row_cnt INTEGER;
BEGIN
  row_cnt := 0;
  OPEN c1;
  LOOP
    FETCH c1 INTO c1r;
    EXIT WHEN c1%NOTFOUND;
    INSERT INTO ebs_sdcr_dn_item_line(
                id, ebs_sdcr_dn_item_id,      trg_src, line_no, status, line_text)
         SELECT id, ebs_sdcr_prod_dt_item_id, trg_src, line_no, status, line_text
           FROM ebs_sdcr_item_line
          WHERE ebs_sdcr_prod_dt_item_id = c1r.id;
    row_cnt := row_cnt + 1;
    IF ( MOD(row_cnt, 1000) = 0 )
    THEN
      dbms_output.put_line('Row: ' || TO_CHAR(row_cnt));
      COMMIT;
    END IF;
  END LOOP;
  CLOSE c1;
  dbms_output.put_line('Row: ' || TO_CHAR(row_cnt));
  COMMIT;
END;
/
@schema-dn-indexes-constraints.ddl
DECLARE
  v_src_ebs_version VARCHAR2(1024);
  v_trg_ebs_version VARCHAR2(1024);
  v_parser_version  VARCHAR2(1024);
  v_parse_startdate DATE;
  v_parse_enddate   DATE;
  v_ebs_dmcr_dnh_id     INTEGER;
  v_ebs_fcr_dnh_id      INTEGER;
  v_ebs_sdcr_dnh_id     INTEGER;
BEGIN
  v_src_ebs_version := '${SRC_EBS_VERSION}';
  v_trg_ebs_version := '${TRG_EBS_VERSION}';

  -----------------------------------------------------------------------------
  -- Store the DataModel model (DMCR)
  -----------------------------------------------------------------------------
  -- Extract the parser version
  SELECT ed.parser_version, ed.parse_startdate, ed.parse_enddate
    INTO v_parser_version,  v_parse_startdate,  v_parse_enddate
    FROM ebs_dmcr ed
   WHERE ed.src_ebs_version = v_src_ebs_version
     AND ed.trg_ebs_version = v_trg_ebs_version;
  -- Remove any history for this parser version
  DELETE ebs_dmcr_dnh_object eddo
   WHERE ebs_dmcr_dnh_id IN (
           SELECT edd.id
             FROM ebs_dmcr_dnh edd
            WHERE edd.src_ebs_version = v_src_ebs_version
              AND edd.trg_ebs_version = v_trg_ebs_version
              AND edd.parser_version  = v_parser_version
              );
  COMMIT;
  DELETE ebs_dmcr_dnh edd
   WHERE edd.src_ebs_version = v_src_ebs_version
     AND edd.trg_ebs_version = v_trg_ebs_version
     AND edd.parser_version  = v_parser_version;
  COMMIT;
  -- Insert into historical tables
  SELECT ebs_dmcr_dnh_seq.nextval
    INTO v_ebs_dmcr_dnh_id
    FROM dual;
  INSERT INTO ebs_dmcr_dnh (
    id, src_ebs_version, trg_ebs_version, parser_version, parse_startdate, parse_enddate )
    VALUES (
    v_ebs_dmcr_dnh_id, v_src_ebs_version, v_trg_ebs_version, v_parser_version, v_parse_startdate, v_parse_enddate );
  COMMIT;
  INSERT INTO ebs_dmcr_dnh_object (
    id, ebs_dmcr_dnh_id, ebs_product_code, change_type, object_type_label, object_type, object_name, change_object_attr )
    SELECT
      eddo.id, v_ebs_dmcr_dnh_id, eddo.ebs_product_code, eddo.change_type, eddo.object_type_label, eddo.object_type, eddo.object_name, eddo.change_object_attr
      FROM ebs_dmcr_dn_object eddo
     WHERE eddo.src_ebs_version = v_src_ebs_version
       AND eddo.trg_ebs_version = v_trg_ebs_version;
  COMMIT;


  -----------------------------------------------------------------------------
  -- Store the Filesystem Change model (FCR)
  -----------------------------------------------------------------------------
  -- Extract the parser version
  SELECT ef.parser_version, ef.parse_startdate, ef.parse_enddate
    INTO v_parser_version,  v_parse_startdate,  v_parse_enddate
    FROM ebs_fcr ef, ebs_fcr_src efs
   WHERE efs.ebs_fcr_id      = ef.id
     AND efs.src_ebs_version = v_src_ebs_version
     AND ef.ebs_version      = v_trg_ebs_version;
  -- Remove any history for this parser version
  DELETE ebs_fcr_dnh_item efdi
   WHERE ebs_fcr_dnh_id IN (
           SELECT efd.id
             FROM ebs_fcr_dnh efd
            WHERE efd.src_ebs_version = v_src_ebs_version
              AND efd.trg_ebs_version = v_trg_ebs_version
              AND efd.parser_version  = v_parser_version
              );
  COMMIT;
  DELETE ebs_fcr_dnh efd
   WHERE efd.src_ebs_version = v_src_ebs_version
     AND efd.trg_ebs_version = v_trg_ebs_version
     AND efd.parser_version  = v_parser_version;
  COMMIT;
  -- Insert into historical tables
  SELECT ebs_fcr_dnh_seq.nextval
    INTO v_ebs_fcr_dnh_id
    FROM dual;
  INSERT INTO ebs_fcr_dnh (
    id, src_ebs_version, trg_ebs_version, parser_version, parse_startdate, parse_enddate )
    VALUES (
    v_ebs_fcr_dnh_id, v_src_ebs_version, v_trg_ebs_version, v_parser_version, v_parse_startdate, v_parse_enddate );
  COMMIT;
  INSERT INTO ebs_fcr_dnh_item (
    id, ebs_fcr_dnh_id, ebs_product_code, filetype_label, action_type, item_filename, item_version, item_src_version )
    SELECT
      efdi.id, v_ebs_fcr_dnh_id, efdi.ebs_product_code, efdi.filetype_label, efdi.action_type, efdi.item_filename, efdi.item_version, efdi.item_src_version
      FROM ebs_fcr_dn_item efdi
     WHERE efdi.src_ebs_version = v_src_ebs_version
       AND efdi.trg_ebs_version = v_trg_ebs_version;
  COMMIT;


  -----------------------------------------------------------------------------
  -- Store the SeedData model (SDCR)
  -----------------------------------------------------------------------------
  -- Extract the parser version
  SELECT es.parser_version, es.parse_startdate, es.parse_enddate
    INTO v_parser_version,  v_parse_startdate,  v_parse_enddate
    FROM ebs_sdcr es, ebs_sdcr_src ess
   WHERE ess.ebs_sdcr_id     = es.id
     AND ess.src_ebs_version = v_src_ebs_version
     AND es.ebs_version      = v_trg_ebs_version;
  -- Remove any history for this parser version
  DELETE ebs_sdcr_dnh_item esdi
   WHERE ebs_sdcr_dnh_id IN (
           SELECT esd.id
             FROM ebs_sdcr_dnh esd
            WHERE esd.src_ebs_version = v_src_ebs_version
              AND esd.trg_ebs_version = v_trg_ebs_version
              AND esd.parser_version  = v_parser_version
              );
  COMMIT;
  DELETE ebs_sdcr_dnh esd
   WHERE esd.src_ebs_version = v_src_ebs_version
     AND esd.trg_ebs_version = v_trg_ebs_version
     AND esd.parser_version  = v_parser_version;
  COMMIT;
  -- Insert into historical tables
  SELECT ebs_sdcr_dnh_seq.nextval
    INTO v_ebs_sdcr_dnh_id
    FROM dual;
  INSERT INTO ebs_sdcr_dnh (
    id, src_ebs_version, trg_ebs_version, parser_version, parse_startdate, parse_enddate )
    VALUES (
    v_ebs_sdcr_dnh_id, v_src_ebs_version, v_trg_ebs_version, v_parser_version, v_parse_startdate, v_parse_enddate );
  COMMIT;
  INSERT INTO ebs_sdcr_dnh_item (
    id, ebs_sdcr_dnh_id, ebs_product_code, datatype_label, action_type, item_object_type, item_product_code, item_object_name )
    SELECT
      esdi.id, v_ebs_sdcr_dnh_id, esdi.ebs_product_code, esdi.datatype_label, esdi.action_type, esdi.item_object_type, esdi.item_product_code, esdi.item_object_name
      FROM ebs_sdcr_dn_item esdi
     WHERE esdi.src_ebs_version = v_src_ebs_version
       AND esdi.trg_ebs_version = v_trg_ebs_version;
  COMMIT;


END;
/
QUIT
ENDSQL
date;
) 1>$LOGFILE 2>&1

