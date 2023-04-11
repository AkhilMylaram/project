
ALTER TABLE ebs_dmcr_dn_object_text
    DROP CONSTRAINT ebs_dmcr_dn_text_2_object_fk;

ALTER TABLE ebs_fcr_dn_item_line
    DROP CONSTRAINT ebs_fcr_dn_item_2_item_fk;

ALTER TABLE ebs_sdcr_dn_item_line
    DROP CONSTRAINT ebs_sdcr_dn_line_2_item_fk;

ALTER TABLE ebs_sdcr_dn_item_line DROP CONSTRAINT ebs_sdcr_dn_item_line_pk;

ALTER TABLE ebs_sdcr_dn_item DROP CONSTRAINT ebs_sdcr_dn_item_pk;

ALTER TABLE ebs_fcr_dn_item_line DROP CONSTRAINT ebs_fcr_dn_item_line_pk;

ALTER TABLE ebs_fcr_dn_item DROP CONSTRAINT ebs_fcr_dn_item_pk;

ALTER TABLE ebs_dmcr_dn_object_text DROP CONSTRAINT ebs_dmcr_dn_object_text_pk;

ALTER TABLE ebs_dmcr_dn_object DROP CONSTRAINT ebs_dmcr_dn_object_pk;



DROP INDEX ebs_sdcr_dn_item_line_pk;

DROP INDEX ebs_sdcr_dn_item_line_fk;

DROP INDEX ebs_sdcr_dn_item_pk;



DROP INDEX ebs_fcr_dn_item_line_pk;

DROP INDEX ebs_fcr_dn_item_line_fk;

DROP INDEX ebs_fcr_dn_item_pk;



DROP INDEX ebs_dmcr_dn_object_text_pk;

DROP INDEX ebs_dmcr_dn_object_text_fk;

DROP INDEX ebs_dmcr_dn_object_pk;














