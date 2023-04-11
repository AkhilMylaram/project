-- Generated by Oracle SQL Developer Data Modeler 19.4.0.350.1424
--   at:        2020-04-07 20:31:48 PDT
--   site:      Oracle Database 11g
--   type:      Oracle Database 11g



CREATE TABLE ebs_dmcr_dn_object (
    id                  INTEGER NOT NULL,
    trg_ebs_version     VARCHAR2(128) NOT NULL,
    src_ebs_version     VARCHAR2(128) NOT NULL,
    ebs_product_code    VARCHAR2(128) NOT NULL,
    change_type         VARCHAR2(128) NOT NULL,
    object_type_label   VARCHAR2(128),
    object_type         VARCHAR2(128),
    object_name         VARCHAR2(128),
    change_object_attr  CLOB
);


CREATE TABLE ebs_dmcr_dn_object_text (
    id                     INTEGER NOT NULL,
    ebs_dmcr_dn_object_id  INTEGER NOT NULL,
    trg_text               CLOB,
    src_text               CLOB
);


CREATE TABLE ebs_fcr_dn_item (
    id                INTEGER NOT NULL,
    trg_ebs_version   VARCHAR2(128) NOT NULL,
    src_ebs_version   VARCHAR2(128) NOT NULL,
    ebs_product_code  VARCHAR2(128) NOT NULL,
    filetype_label    VARCHAR2(128),
    action_type       VARCHAR2(128),
    item_filename     VARCHAR2(1024),
    item_version      VARCHAR2(128),
    item_src_version  VARCHAR2(128)
);


CREATE TABLE ebs_fcr_dn_item_line (
    id                  INTEGER NOT NULL,
    ebs_fcr_dn_item_id  INTEGER NOT NULL,
    line_no             INTEGER NOT NULL,
    trg_line_no         INTEGER,
    trg_status          VARCHAR2(128),
    trg_text            CLOB,
    src_line_no         INTEGER,
    src_status          VARCHAR2(128),
    src_text            CLOB
);


CREATE TABLE ebs_sdcr_dn_item (
    id                 INTEGER NOT NULL,
    trg_ebs_version    VARCHAR2(128) NOT NULL,
    src_ebs_version    VARCHAR2(128) NOT NULL,
    ebs_product_code   VARCHAR2(128) NOT NULL,
    datatype_label     VARCHAR2(128) NOT NULL,
    action_type        VARCHAR2(128) NOT NULL,
    item_object_type   VARCHAR2(128),
    item_product_code  VARCHAR2(128),
    item_object_name   VARCHAR2(1024)
);


CREATE TABLE ebs_sdcr_dn_item_line (
    id                   INTEGER NOT NULL,
    ebs_sdcr_dn_item_id  INTEGER NOT NULL,
    trg_src              VARCHAR2(128) NOT NULL,
    line_no              INTEGER NOT NULL,
    status               VARCHAR2(128),
    line_text            CLOB
);
