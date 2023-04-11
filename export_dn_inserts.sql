set sqlformat insert;
SPOOL export_dn.sql
SELECT * FROM ebs_dmcr_dn_object ;
SELECT * FROM ebs_fcr_dn_item    ;
SELECT * FROM ebs_sdcr_dn_item   ;
SPOOL OFF
SPOOL export_dn_text.sql
SELECT * FROM ebs_dmcr_dn_object_text ;
SELECT * FROM ebs_fcr_dn_item_line    ;
SELECT * FROM ebs_sdcr_dn_item_line   ;
SPOOL OFF
