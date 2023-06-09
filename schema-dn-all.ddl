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

CREATE UNIQUE INDEX ebs_dmcr_dn_object_pk ON
    ebs_dmcr_dn_object (
        id
    ASC );

ALTER TABLE ebs_dmcr_dn_object ADD CONSTRAINT ebs_dmcr_dn_object_pk PRIMARY KEY ( id );

CREATE TABLE ebs_dmcr_dn_object_text (
    id                     INTEGER NOT NULL,
    ebs_dmcr_dn_object_id  INTEGER NOT NULL,
    trg_text               CLOB,
    src_text               CLOB
);

CREATE UNIQUE INDEX ebs_dmcr_dn_object_text_pk ON
    ebs_dmcr_dn_object_text (
        id
    ASC );

CREATE INDEX ebs_dmcr_dn_object_text_fk ON
    ebs_dmcr_dn_object_text (
        ebs_dmcr_dn_object_id
    ASC );

ALTER TABLE ebs_dmcr_dn_object_text ADD CONSTRAINT ebs_dmcr_dn_object_text_pk PRIMARY KEY ( id );

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

CREATE UNIQUE INDEX ebs_fcr_dn_item_pk ON
    ebs_fcr_dn_item (
        id
    ASC );

ALTER TABLE ebs_fcr_dn_item ADD CONSTRAINT ebs_fcr_dn_item_pk PRIMARY KEY ( id );

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

CREATE UNIQUE INDEX ebs_fcr_dn_item_line_pk ON
    ebs_fcr_dn_item_line (
        id
    ASC );

CREATE INDEX ebs_fcr_dn_item_line_fk ON
    ebs_fcr_dn_item_line (
        ebs_fcr_dn_item_id
    ASC );

ALTER TABLE ebs_fcr_dn_item_line ADD CONSTRAINT ebs_fcr_dn_item_line_pk PRIMARY KEY ( id );

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

CREATE UNIQUE INDEX ebs_sdcr_dn_item_pk ON
    ebs_sdcr_dn_item (
        id
    ASC );

ALTER TABLE ebs_sdcr_dn_item ADD CONSTRAINT ebs_sdcr_dn_item_pk PRIMARY KEY ( id );

CREATE TABLE ebs_sdcr_dn_item_line (
    id                   INTEGER NOT NULL,
    ebs_sdcr_dn_item_id  INTEGER NOT NULL,
    trg_src              VARCHAR2(128) NOT NULL,
    line_no              INTEGER NOT NULL,
    status               VARCHAR2(128),
    line_text            CLOB
);

CREATE UNIQUE INDEX ebs_sdcr_dn_item_line_pk ON
    ebs_sdcr_dn_item_line (
        id
    ASC );

CREATE INDEX ebs_sdcr_dn_item_line_fk ON
    ebs_sdcr_dn_item_line (
        ebs_sdcr_dn_item_id
    ASC );

ALTER TABLE ebs_sdcr_dn_item_line ADD CONSTRAINT ebs_sdcr_dn_item_line_pk PRIMARY KEY ( id );

ALTER TABLE ebs_dmcr_dn_object_text
    ADD CONSTRAINT ebs_dmcr_dn_text_2_object_fk FOREIGN KEY ( ebs_dmcr_dn_object_id )
        REFERENCES ebs_dmcr_dn_object ( id );

ALTER TABLE ebs_fcr_dn_item_line
    ADD CONSTRAINT ebs_fcr_dn_item_2_item_fk FOREIGN KEY ( ebs_fcr_dn_item_id )
        REFERENCES ebs_fcr_dn_item ( id );

ALTER TABLE ebs_sdcr_dn_item_line
    ADD CONSTRAINT ebs_sdcr_dn_line_2_item_fk FOREIGN KEY ( ebs_sdcr_dn_item_id )
        REFERENCES ebs_sdcr_dn_item ( id );

CREATE OR REPLACE VIEW EBS_DMCR_OBJECT_V ( id, trg_ebs_version, src_ebs_version, ebs_product_code, change_type, object_type_label, object_type, object_name, change_object_attr ) AS
SELECT
    ebs_dmcr_object.id,
    ebs_dmcr.trg_ebs_version,
    ebs_dmcr.src_ebs_version,
    ebs_dmcr_product.ebs_product_code,
    ebs_dmcr_object.change_type,
    ebs_dmcr_object.object_type_label,
    ebs_dmcr_object.object_type,
    ebs_dmcr_object.object_name,
    ebs_dmcr_object.change_object_attr
FROM
         ebs_dmcr
    INNER JOIN ebs_dmcr_product ON ebs_dmcr.id = ebs_dmcr_product.ebs_dmcr_id
    INNER JOIN ebs_dmcr_object ON ebs_dmcr_product.id = ebs_dmcr_object.ebs_dmcr_product_id 
;

CREATE OR REPLACE VIEW EBS_FCR_ITEM_V ( id, trg_ebs_version, src_ebs_version, ebs_product_code, filetype_label, action_type, item_filename, item_version, item_src_version ) AS
SELECT
    ebs_fcr_prod_ft_item.id,
    ebs_fcr.ebs_version AS trg_ebs_version,
    ebs_fcr_src.src_ebs_version,
    ebs_fcr_product.ebs_product_code,
    ebs_fcr_prod_filetype.filetype_label,
    ebs_fcr_prod_ft_item.action_type,
    ebs_fcr_prod_ft_item.item_filename,
    ebs_fcr_prod_ft_item.item_version,
    ebs_fcr_prod_ft_item.item_src_version
FROM
         ebs_fcr
    INNER JOIN ebs_fcr_src ON ebs_fcr.id = ebs_fcr_src.ebs_fcr_id
    INNER JOIN ebs_fcr_product ON ebs_fcr_src.id = ebs_fcr_product.ebs_fcr_src_id
    INNER JOIN ebs_fcr_prod_filetype ON ebs_fcr_product.id = ebs_fcr_prod_filetype.ebs_fcr_product_id
    INNER JOIN ebs_fcr_prod_ft_item ON ebs_fcr_prod_filetype.id = ebs_fcr_prod_ft_item.ebs_fcr_prod_filetype_id 
;

CREATE OR REPLACE VIEW EBS_SDCR_ITEM_V ( id, trg_ebs_version, src_ebs_version, ebs_product_code, datatype_label, action_type, item_object_type, item_product_code, item_object_name ) AS
SELECT
    ebs_sdcr_prod_dt_item.id,
    ebs_sdcr.ebs_version AS trg_ebs_version,
    ebs_sdcr_src.src_ebs_version,
    ebs_sdcr_product.ebs_product_code,
    ebs_sdcr_prod_datatype.datatype_label,
    ebs_sdcr_prod_dt_item.action_type,
    ebs_sdcr_prod_dt_item.item_object_type,
    ebs_sdcr_prod_dt_item.item_product_code,
    ebs_sdcr_prod_dt_item.item_object_name
FROM
         ebs_sdcr
    INNER JOIN ebs_sdcr_src ON ebs_sdcr.id = ebs_sdcr_src.ebs_sdcr_id
    INNER JOIN ebs_sdcr_product ON ebs_sdcr_src.id = ebs_sdcr_product.ebs_sdcr_src_id
    INNER JOIN ebs_sdcr_prod_datatype ON ebs_sdcr_product.id = ebs_sdcr_prod_datatype.ebs_sdcr_product_id
    INNER JOIN ebs_sdcr_prod_dt_item ON ebs_sdcr_prod_datatype.id = ebs_sdcr_prod_dt_item.ebs_sdcr_prod_datatype_id 
;



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             6
-- CREATE INDEX                             9
-- ALTER TABLE                              9
-- CREATE VIEW                              3
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
