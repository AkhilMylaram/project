SET ECHO OFF
SET TERMOUT OFF
COLUMN LOGNAME NEW_VALUE FULL_LOGNAME NOPRINT;
SELECT name
     ||'.'
     || USERENV('SCHEMAID')
     ||'.'
     || TO_CHAR(SYSDATE, 'YYYYMMDD.HH24MISS') LOGNAME
 FROM   v$database;

SET HEADING ON
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 1000
SET LINESIZE 255
SET TRIMSPOOL ON
SET SERVEROUTPUT ON FORMAT WRAPPED
EXEC DBMS_OUTPUT.ENABLE(1000000);
DEFINE SOURCE_EBS_VERSION=&&1
DEFINE TARGET_EBS_VERSION=&&2
SPOOL validate_count-&SOURCE_EBS_VERSION.-&TARGET_EBS_VERSION.-&FULL_LOGNAME..log
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON
REM ============================================================================
REM Validation of File Comparison Report
REM ============================================================================
DECLARE
  CURSOR c1 IS
  SELECT ef.ebs_version, efs.src_ebs_version, efp.ebs_product_code, efp.id "EBS_FCR_PRODUCT_ID"
       , efp.num_added
       , efp.num_removed
       , efp.num_stubbed
       , efp.num_changed
       , efp.num_unchanged
    FROM EBS_FCR ef, EBS_FCR_SRC efs, EBS_FCR_PRODUCT efp
   WHERE ef.ebs_version          = '&TARGET_EBS_VERSION.'
     AND efs.ebs_fcr_id          = ef.id
     AND efs.src_ebs_version     = '&SOURCE_EBS_VERSION.'
     AND efp.ebs_fcr_src_id      = efs.id
   ORDER BY efp.ebs_product_code;
  c1r c1%ROWTYPE;

  v_sum_num_added     NUMBER;
  v_sum_num_stubbed   NUMBER;
  v_sum_num_removed   NUMBER;
  v_sum_num_changed   NUMBER;
  v_sum_num_unchanged NUMBER;

  v_cnt_num_added     NUMBER;
  v_cnt_num_stubbed   NUMBER;
  v_cnt_num_removed   NUMBER;
  v_cnt_num_changed   NUMBER;
  v_cnt_num_unchanged NUMBER;

  v_cnt_product_total NUMBER;
  v_cnt_product_ok    NUMBER;
  CURSOR c2(p_ebs_fcr_product_id NUMBER) IS
    SELECT efpf.id "EBS_FCR_PROD_FILETYPE_ID", efpf.ebs_fcr_product_id, efpf.filetype_label, efpf.filetype_description
         , efpf.num_added
         , efpf.num_removed
         , efpf.num_stubbed
         , efpf.num_changed
         , efpf.num_unchanged
      FROM ebs_fcr_prod_filetype efpf
     WHERE efpf.ebs_fcr_product_id = p_ebs_fcr_product_id
     ORDER BY efpf.filetype_label;
  c2r c2%ROWTYPE;
  CURSOR c3(p_ebs_fcr_prod_filetype_id NUMBER) IS
      SELECT efpfi.action_type, COUNT(1) "CNT_NUM"
        FROM ebs_fcr_prod_ft_item efpfi
       WHERE efpfi.ebs_fcr_prod_filetype_id = p_ebs_fcr_prod_filetype_id
       GROUP BY efpfi.action_type;
  c3r c3%ROWTYPE;
BEGIN
  dbms_output.put_line('Validation for File Comparison Report');
  dbms_output.put_line('Source EBS version: &SOURCE_EBS_VERSION');
  dbms_output.put_line('Target EBS version: &TARGET_EBS_VERSION');
  OPEN c1;
  LOOP
    FETCH c1 INTO c1r;
    EXIT WHEN c1%NOTFOUND;
    SELECT SUM(num_added)     "SUM_NUM_ADDED"
         , SUM(num_removed)   "SUM_NUM_REMOVED"
         , SUM(num_stubbed)   "SUM_NUM_STUBBED"
         , SUM(num_changed)   "SUM_NUM_CHANGED"
         , SUM(num_unchanged) "SUM_NUM_UNCHANGED"
      INTO v_sum_num_added, v_sum_num_removed, v_sum_num_stubbed, v_sum_num_changed, v_sum_num_unchanged
      FROM EBS_FCR_PROD_FILETYPE efpf
     WHERE efpf.ebs_fcr_product_id = c1r.ebs_fcr_product_id;
    dbms_output.put(c1r.ebs_product_code);
    IF ( c1r.num_added     = v_sum_num_added
     AND c1r.num_removed   = v_sum_num_removed
     AND c1r.num_stubbed   = v_sum_num_stubbed
     AND c1r.num_changed   = v_sum_num_changed
     AND c1r.num_unchanged = v_sum_num_unchanged ) THEN
      dbms_output.put_line(' OK');
    ELSE
      dbms_output.put_line(' ' 
        ||        TO_CHAR(c1r.num_added)     || '-' || TO_CHAR(v_sum_num_added)
        || ' ' || TO_CHAR(c1r.num_removed)   || '-' || TO_CHAR(v_sum_num_removed)
        || ' ' || TO_CHAR(c1r.num_stubbed)   || '-' || TO_CHAR(v_sum_num_stubbed)
        || ' ' || TO_CHAR(c1r.num_changed)   || '-' || TO_CHAR(v_sum_num_changed)
        || ' ' || TO_CHAR(c1r.num_unchanged) || '-' || TO_CHAR(v_sum_num_unchanged)
        );
    END IF;
    v_cnt_product_total := 0;
    v_cnt_product_ok    := 0;
    OPEN c2(c1r.ebs_fcr_product_id);
    LOOP
      FETCH c2 INTO c2r;
      EXIT WHEN c2%NOTFOUND;
      v_cnt_num_added := 0;
      v_cnt_num_removed := 0;
      v_cnt_num_stubbed := 0;
      v_cnt_num_changed := 0;
      v_cnt_num_unchanged := 0;
      OPEN c3(c2r.ebs_fcr_prod_filetype_id);
      LOOP
        FETCH c3 INTO c3r;
        EXIT WHEN c3%NOTFOUND;
        IF (    c3r.action_type = 'Added' ) THEN
          v_cnt_num_added := c3r.cnt_num;
        ELSIF ( c3r.action_type = 'Removed' ) THEN
          v_cnt_num_removed := c3r.cnt_num;
        ELSIF ( c3r.action_type = 'Stubbed' ) THEN
          v_cnt_num_stubbed := c3r.cnt_num;
        ELSIF ( c3r.action_type = 'Changed' ) THEN
          v_cnt_num_changed := c3r.cnt_num;
        ELSIF ( c3r.action_type = 'Unchanged' ) THEN
          v_cnt_num_unchanged := c3r.cnt_num;
        END IF;
      END LOOP;
      CLOSE c3;

      v_cnt_product_total := v_cnt_product_total + 1;
      IF ( c2r.num_added     = v_cnt_num_added
       AND c2r.num_removed   = v_cnt_num_removed
       AND c2r.num_stubbed   = v_cnt_num_stubbed
       AND c2r.num_changed   = v_cnt_num_changed
       AND c2r.num_unchanged = v_cnt_num_unchanged ) THEN
        v_cnt_product_ok := v_cnt_product_ok + 1;
      ELSE
        dbms_output.put('-' || c2r.filetype_label);
        dbms_output.put_line(' ' 
          ||        TO_CHAR(c2r.num_added)     || '-' || TO_CHAR(v_cnt_num_added)
          || ' ' || TO_CHAR(c2r.num_removed)   || '-' || TO_CHAR(v_cnt_num_removed)
          || ' ' || TO_CHAR(c2r.num_stubbed)   || '-' || TO_CHAR(v_cnt_num_stubbed)
          || ' ' || TO_CHAR(c2r.num_changed)   || '-' || TO_CHAR(v_cnt_num_changed)
          || ' ' || TO_CHAR(c2r.num_unchanged) || '-' || TO_CHAR(v_cnt_num_unchanged)
          );
      END IF;
    END LOOP;
    CLOSE c2;
    dbms_output.put_line('  Product Total: ' || TO_CHAR(v_cnt_product_total) 
                      || ' OK: ' || TO_CHAR(v_cnt_product_ok)
                      || ' Missed: ' || TO_CHAR(v_cnt_product_total - v_cnt_product_ok));
  END LOOP;
  CLOSE c1;
END;
/
REM ============================================================================
REM Validation of Data Model Comparison Report
REM ============================================================================
DECLARE
  CURSOR c1 IS
  SELECT ed.trg_ebs_version, ed.src_ebs_version, edp.ebs_product_code, edp.id "EBS_DMCR_PRODUCT_ID"
       , edp.num_added
       , edp.num_removed
       , edp.num_changed
    FROM ebs_dmcr ed, ebs_dmcr_product edp
   WHERE ed.src_ebs_version      = '&SOURCE_EBS_VERSION.'
     AND ed.trg_ebs_version      = '&TARGET_EBS_VERSION.'
     AND edp.ebs_dmcr_id          = ed.id
   ORDER BY edp.ebs_product_code;
  c1r c1%ROWTYPE;

  CURSOR c2(p_ebs_dmcr_product_id NUMBER) IS
  SELECT edo.change_type, COUNT(1) "CNT_NUM"
    FROM ebs_dmcr_object edo
   WHERE edo.ebs_dmcr_product_id = p_ebs_dmcr_product_id
   GROUP BY change_type;
  c2r c2%ROWTYPE;

  v_cnt_num_added     NUMBER;
  v_cnt_num_removed   NUMBER;
  v_cnt_num_changed   NUMBER;

  v_cnt_product_total NUMBER;
  v_cnt_product_ok    NUMBER;
BEGIN
  dbms_output.put_line('Validation for Data Model Comparison Report');
  dbms_output.put_line('Source EBS version: &SOURCE_EBS_VERSION');
  dbms_output.put_line('Target EBS version: &TARGET_EBS_VERSION');

  v_cnt_product_total := 0;
  v_cnt_product_ok    := 0;
  OPEN c1;
  LOOP
    FETCH c1 INTO c1r;
    EXIT WHEN c1%NOTFOUND;
    dbms_output.put(c1r.ebs_product_code);

    v_cnt_num_added   := 0;
    v_cnt_num_removed := 0;
    v_cnt_num_changed := 0;
    OPEN c2(c1r.ebs_dmcr_product_id);
    LOOP
      FETCH c2 INTO c2r;
      EXIT WHEN c2%NOTFOUND;
      IF (    c2r.change_type = 'Added' ) THEN
        v_cnt_num_added   := c2r.cnt_num;
      ELSIF ( c2r.change_type = 'Removed' ) THEN
        v_cnt_num_removed := c2r.cnt_num;
      ELSIF ( c2r.change_type = 'Changed' ) THEN
        v_cnt_num_changed := c2r.cnt_num;
      END IF;
    END LOOP;
    CLOSE c2;

    IF ( c1r.num_added     = v_cnt_num_added
     AND c1r.num_removed   = v_cnt_num_removed
     AND c1r.num_changed   = v_cnt_num_changed ) THEN
      dbms_output.put_line(' OK');
    ELSE
      dbms_output.put_line(' ' 
        ||        TO_CHAR(c1r.num_added)     || '-' || TO_CHAR(v_cnt_num_added)
        || ' ' || TO_CHAR(c1r.num_removed)   || '-' || TO_CHAR(v_cnt_num_removed)
        || ' ' || TO_CHAR(c1r.num_changed)   || '-' || TO_CHAR(v_cnt_num_changed)
        );
    END IF;
  END LOOP;
  CLOSE c1;
END;
/
REM ============================================================================
REM Validation of Seed Data Comparison Report
REM ============================================================================
DECLARE
  CURSOR c1 IS
  SELECT es.ebs_version, ess.src_ebs_version, esp.ebs_product_code, esp.id "EBS_SDCR_PRODUCT_ID"
       , esp.num_added
       , esp.num_removed
       , esp.num_changed
    FROM ebs_sdcr es, ebs_sdcr_src ess, ebs_sdcr_product esp
   WHERE ess.src_ebs_version      = '&SOURCE_EBS_VERSION'
     AND es.ebs_version           = '&TARGET_EBS_VERSION'
     AND ess.ebs_sdcr_id          = es.id
     AND esp.ebs_sdcr_src_id      = ess.id
   ORDER BY esp.ebs_product_code;
  c1r c1%ROWTYPE;

  v_tot_prod_num_added     NUMBER;
  v_tot_prod_num_removed   NUMBER;
  v_tot_prod_num_changed   NUMBER;

  CURSOR c2(p_ebs_sdcr_product_id NUMBER) IS
  SELECT espd.datatype_label, espd.id "EBS_SDCR_PROD_DATATYPE_ID"
       , espd.num_added
       , espd.num_removed
       , espd.num_changed
    FROM ebs_sdcr_prod_datatype espd
   WHERE espd.ebs_sdcr_product_id = p_ebs_sdcr_product_id;
  c2r c2%ROWTYPE;

  CURSOR c3(p_ebs_sdcr_prod_datatype_id NUMBER) IS
  SELECT espdi.action_type, COUNT(1) "CNT_NUM"
    FROM ebs_sdcr_prod_dt_item espdi
   WHERE espdi.ebs_sdcr_prod_datatype_id = p_ebs_sdcr_prod_datatype_id
   GROUP BY espdi.action_type;
  c3r c3%ROWTYPE;

  v_cnt_num_added     NUMBER;
  v_cnt_num_removed   NUMBER;
  v_cnt_num_changed   NUMBER;

BEGIN
  dbms_output.put_line('Validation for Seed Data Comparison Report');
  dbms_output.put_line('Source EBS version: &SOURCE_EBS_VERSION');
  dbms_output.put_line('Target EBS version: &TARGET_EBS_VERSION');

  OPEN c1;
  LOOP
    FETCH c1 INTO c1r;
    EXIT WHEN c1%NOTFOUND;
    dbms_output.put(c1r.ebs_product_code);

    v_tot_prod_num_added   := 0;
    v_tot_prod_num_removed := 0;
    v_tot_prod_num_changed := 0;
    SELECT SUM(espd.num_added)   "TOT_PROD_NUM_ADDED"
         , SUM(espd.num_removed) "TOT_PROD_NUM_REMOVED"
         , SUM(espd.num_changed) "TOT_PROD_NUM_CHANGED"
      INTO v_tot_prod_num_added
         , v_tot_prod_num_removed
         , v_tot_prod_num_changed
      FROM ebs_sdcr_prod_datatype espd
     WHERE espd.ebs_sdcr_product_id = c1r.ebs_sdcr_product_id;
    IF ( c1r.num_added   = v_tot_prod_num_added 
     AND c1r.num_removed = v_tot_prod_num_removed
     AND c1r.num_changed = v_tot_prod_num_changed )
    THEN
      dbms_output.put_line(' OK');
    ELSE
      dbms_output.put_line(' ' || TO_CHAR(c1r.num_added)   || '-' || TO_CHAR(v_tot_prod_num_added) 
                        || ' ' || TO_CHAR(c1r.num_removed) || '-' || TO_CHAR(v_tot_prod_num_removed) 
                        || ' ' || TO_CHAR(c1r.num_changed) || '-' || TO_CHAR(v_tot_prod_num_changed) );
    END IF;

    OPEN c2(c1r.ebs_sdcr_product_id);
    LOOP
      FETCH c2 INTO c2r;
      EXIT WHEN c2%NOTFOUND;
      -- dbms_output.put('  ' || c2r.datatype_label);

      v_cnt_num_added   := 0;
      v_cnt_num_removed := 0;
      v_cnt_num_changed := 0;

      OPEN c3(c2r.ebs_sdcr_prod_datatype_id);
      LOOP
        FETCH c3 INTO c3r;
        EXIT WHEN c3%NOTFOUND;
        IF (    c3r.action_type = 'Added' ) THEN
          v_cnt_num_added   := c3r.cnt_num;
        ELSIF ( c3r.action_type = 'Removed' ) THEN
          v_cnt_num_removed := c3r.cnt_num;
        ELSIF ( c3r.action_type = 'Changed' ) THEN
          v_cnt_num_changed := c3r.cnt_num;
        END IF;
      END LOOP;
      CLOSE c3;

      IF ( c2r.num_added   = v_cnt_num_added 
       AND c2r.num_removed = v_cnt_num_removed
       AND c2r.num_changed = v_cnt_num_changed )
      THEN
        -- dbms_output.put_line(' OK');
        NULL;
      ELSE
        dbms_output.put('  ' || c2r.datatype_label);
        dbms_output.put_line(' ' || TO_CHAR(c2r.num_added)   || '-' || TO_CHAR(v_cnt_num_added) 
                          || ' ' || TO_CHAR(c2r.num_removed) || '-' || TO_CHAR(v_cnt_num_removed) 
                          || ' ' || TO_CHAR(c2r.num_changed) || '-' || TO_CHAR(v_cnt_num_changed) );
      END IF;

    END LOOP;
    CLOSE c2;

  END LOOP;
  CLOSE c1;
END;
/
SPOOL OFF
