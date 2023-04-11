set sqlformat insert;
spool export_text_lines.sql
select * from ebs_dmcr_text;
select * from ebs_fcr_ft_item_line;
select * from ebs_sdcr_item_line;
spool off