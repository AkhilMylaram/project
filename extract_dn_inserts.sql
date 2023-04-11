set sqlformat insert;
spool export_dn_inserts.sql
select * from ebs_dmcr_dn_item;
select * from ebs_fcr_dn_item;
select * from ebs_sdcr_dn_item;
spool off