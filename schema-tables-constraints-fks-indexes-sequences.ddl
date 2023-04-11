-- Generated by Oracle SQL Developer Data Modeler 19.4.0.350.1424
--   at:        2020-04-17 15:09:58 PDT
--   site:      Oracle Database 11g
--   type:      Oracle Database 11g



CREATE SEQUENCE ebs_dmcr_object_seq;

CREATE SEQUENCE ebs_dmcr_product_seq;

CREATE SEQUENCE ebs_dmcr_seq;

CREATE SEQUENCE ebs_dmcr_text_seq;

CREATE SEQUENCE ebs_family_seq;

CREATE SEQUENCE ebs_fcr_ft_item_line_seq;

CREATE SEQUENCE ebs_fcr_prod_filetype_seq;

CREATE SEQUENCE ebs_fcr_prod_ft_item_seq;

CREATE SEQUENCE ebs_fcr_product_seq;

CREATE SEQUENCE ebs_fcr_seq;

CREATE SEQUENCE ebs_fcr_src_seq;

CREATE SEQUENCE ebs_product_seq;

CREATE SEQUENCE ebs_sdcr_item_line_seq;

CREATE SEQUENCE ebs_sdcr_prod_datatype_seq;

CREATE SEQUENCE ebs_sdcr_prod_dt_item_seq;

CREATE SEQUENCE ebs_sdcr_product_seq;

CREATE SEQUENCE ebs_sdcr_seq;

CREATE SEQUENCE ebs_sdcr_src_seq;

CREATE SEQUENCE ebs_version_seq;

CREATE TABLE ebs_dmcr (
    id                  INTEGER NOT NULL,
    trg_ebs_version_id  INTEGER NOT NULL,
    trg_ebs_version     VARCHAR2(128) NOT NULL,
    src_ebs_version_id  INTEGER NOT NULL,
    src_ebs_version     VARCHAR2(128) NOT NULL,
    ebs_dmcr_dir_name   VARCHAR2(1024),
    parser_version      VARCHAR2(128),
    parse_startdate     DATE,
    parse_enddate       DATE
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_pk ON
    ebs_dmcr (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_nk ON
    ebs_dmcr (
        trg_ebs_version
    ASC,
        src_ebs_version
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_nk2 ON
    ebs_dmcr (
        trg_ebs_version_id
    ASC,
        src_ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE INDEX ebs_dmcr_trg_fk ON
    ebs_dmcr (
        trg_ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE INDEX ebs_dmcr_src_fk ON
    ebs_dmcr (
        src_ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_dmcr ADD CONSTRAINT ebs_dmcr_pk PRIMARY KEY ( id );

ALTER TABLE ebs_dmcr ADD CONSTRAINT ebs_dmcr_nk UNIQUE ( trg_ebs_version,
                                                         src_ebs_version );

ALTER TABLE ebs_dmcr ADD CONSTRAINT ebs_dmcr_nk2 UNIQUE ( trg_ebs_version_id,
                                                          src_ebs_version_id );

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
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_dn_object_pk ON
    ebs_dmcr_dn_object (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_dmcr_dn_object ADD CONSTRAINT ebs_dmcr_dn_object_pk PRIMARY KEY ( id );

CREATE TABLE ebs_dmcr_dn_object_text (
    id                     INTEGER NOT NULL,
    ebs_dmcr_dn_object_id  INTEGER NOT NULL,
    trg_text               CLOB,
    src_text               CLOB
)
LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_dn_object_text_pk ON
    ebs_dmcr_dn_object_text (
        id
    ASC )
        LOGGING;

CREATE INDEX ebs_dmcr_dn_object_text_fk ON
    ebs_dmcr_dn_object_text (
        ebs_dmcr_dn_object_id
    ASC )
        LOGGING;

ALTER TABLE ebs_dmcr_dn_object_text ADD CONSTRAINT ebs_dmcr_dn_object_text_pk PRIMARY KEY ( id );

CREATE TABLE ebs_dmcr_object (
    id                   INTEGER NOT NULL,
    ebs_dmcr_product_id  INTEGER NOT NULL,
    object_type_label    VARCHAR2(128) NOT NULL,
    object_type          VARCHAR2(128) NOT NULL,
    object_name          VARCHAR2(128) NOT NULL,
    change_type          VARCHAR2(128) NOT NULL,
    change_object_attr   CLOB
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_object_pk ON
    ebs_dmcr_object (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_object_nk ON
    ebs_dmcr_object (
        ebs_dmcr_product_id
    ASC,
        object_type
    ASC,
        object_name
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_dmcr_object ADD CONSTRAINT ebs_dmcr_object_pk PRIMARY KEY ( id );

ALTER TABLE ebs_dmcr_object
    ADD CONSTRAINT ebs_dmcr_object_nk UNIQUE ( ebs_dmcr_product_id,
                                               object_type,
                                               object_name );

CREATE TABLE ebs_dmcr_product (
    id                INTEGER NOT NULL,
    ebs_dmcr_id       INTEGER NOT NULL,
    ebs_product_id    INTEGER NOT NULL,
    ebs_product_code  VARCHAR2(128) NOT NULL,
    num_added         INTEGER,
    num_removed       INTEGER,
    num_changed       INTEGER
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_product_pk ON
    ebs_dmcr_product (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_product_nk ON
    ebs_dmcr_product (
        ebs_dmcr_id
    ASC,
        ebs_product_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_dmcr_product ADD CONSTRAINT ebs_dmcr_product_pk PRIMARY KEY ( id );

ALTER TABLE ebs_dmcr_product ADD CONSTRAINT ebs_dmcr_product_nk UNIQUE ( ebs_dmcr_id,
                                                                         ebs_product_id );

CREATE TABLE ebs_dmcr_text (
    id                  INTEGER NOT NULL,
    ebs_dmcr_object_id  INTEGER NOT NULL,
    trg_text            CLOB,
    src_text            CLOB
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_text_pk ON
    ebs_dmcr_text (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_dmcr_text_nk ON
    ebs_dmcr_text (
        ebs_dmcr_object_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_dmcr_text ADD CONSTRAINT ebs_dmcr_text_pk PRIMARY KEY ( id );

ALTER TABLE ebs_dmcr_text ADD CONSTRAINT ebs_dmcr_text_nk UNIQUE ( ebs_dmcr_object_id );

CREATE TABLE ebs_family (
    id                      INTEGER NOT NULL,
    ebs_version_id          INTEGER NOT NULL,
    ebs_family_code         VARCHAR2(128) NOT NULL,
    ebs_family_description  VARCHAR2(1024)
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_family_pk ON
    ebs_family (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_family_nk ON
    ebs_family (
        ebs_version_id
    ASC,
        ebs_family_code
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_family ADD CONSTRAINT ebs_family_pk PRIMARY KEY ( id );

ALTER TABLE ebs_family ADD CONSTRAINT ebs_family_nk UNIQUE ( ebs_version_id,
                                                             ebs_family_code );

CREATE TABLE ebs_fcr (
    id                INTEGER NOT NULL,
    ebs_version_id    INTEGER NOT NULL,
    ebs_version       VARCHAR2(128) NOT NULL,
    ebs_fcr_dir_name  VARCHAR2(1024),
    parser_version    VARCHAR2(128),
    parse_startdate   DATE,
    parse_enddate     DATE
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_pk ON
    ebs_fcr (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_fcr_nk ON
    ebs_fcr (
        ebs_version
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_fcr_fk ON
    ebs_fcr (
        ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_fcr ADD CONSTRAINT ebs_fcr_pk PRIMARY KEY ( id );

ALTER TABLE ebs_fcr ADD CONSTRAINT ebs_fcr_nk UNIQUE ( ebs_version );

ALTER TABLE ebs_fcr ADD CONSTRAINT ebs_fcr_fk UNIQUE ( ebs_version_id );

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
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_dn_item_pk ON
    ebs_fcr_dn_item (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

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
)
LOGGING;

CREATE UNIQUE INDEX ebs_fcr_dn_item_line_pk ON
    ebs_fcr_dn_item_line (
        id
    ASC )
        LOGGING;

CREATE INDEX ebs_fcr_dn_item_line_fk ON
    ebs_fcr_dn_item_line (
        ebs_fcr_dn_item_id
    ASC )
        LOGGING;

ALTER TABLE ebs_fcr_dn_item_line ADD CONSTRAINT ebs_fcr_dn_item_line_pk PRIMARY KEY ( id );

CREATE TABLE ebs_fcr_ft_item_line (
    id                       INTEGER NOT NULL,
    ebs_fcr_prod_ft_item_id  INTEGER NOT NULL,
    line_no                  INTEGER NOT NULL,
    trg_line_no              INTEGER,
    trg_status               VARCHAR2(128),
    trg_text                 CLOB,
    src_line_no              INTEGER,
    src_status               VARCHAR2(128),
    src_text                 CLOB
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_ft_item_line_pk ON
    ebs_fcr_ft_item_line (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_fcr_ft_item_line_nk ON
    ebs_fcr_ft_item_line (
        ebs_fcr_prod_ft_item_id
    ASC,
        line_no
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_fcr_ft_item_line ADD CONSTRAINT ebs_fcr_ft_item_line_pk PRIMARY KEY ( id );

ALTER TABLE ebs_fcr_ft_item_line ADD CONSTRAINT ebs_fcr_ft_item_line_nk UNIQUE ( ebs_fcr_prod_ft_item_id,
                                                                                 line_no );

CREATE TABLE ebs_fcr_prod_filetype (
    id                    INTEGER NOT NULL,
    ebs_fcr_product_id    INTEGER NOT NULL,
    filetype_label        VARCHAR2(128) NOT NULL,
    filetype_description  VARCHAR2(1024),
    num_added             INTEGER,
    num_removed           INTEGER,
    num_stubbed           INTEGER,
    num_changed           INTEGER,
    num_unchanged         INTEGER
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_prod_filetype_pk ON
    ebs_fcr_prod_filetype (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_fcr_prod_filetype_nk ON
    ebs_fcr_prod_filetype (
        ebs_fcr_product_id
    ASC,
        filetype_label
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_fcr_prod_filetype ADD CONSTRAINT ebs_fcr_prod_filetype_pk PRIMARY KEY ( id );

ALTER TABLE ebs_fcr_prod_filetype ADD CONSTRAINT ebs_fcr_prod_filetype_nk UNIQUE ( ebs_fcr_product_id,
                                                                                   filetype_label );

CREATE TABLE ebs_fcr_prod_ft_item (
    id                         INTEGER NOT NULL,
    ebs_fcr_prod_filetype_id   INTEGER NOT NULL,
    action_type                VARCHAR2(128) NOT NULL,
    item_filename              VARCHAR2(1024) NOT NULL,
    item_version               VARCHAR2(128),
    item_src_version           VARCHAR2(128),
    item_comparison_html_path  VARCHAR2(1024)
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_prod_ft_item_pk ON
    ebs_fcr_prod_ft_item (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE INDEX ebs_fcr_prod_ft_item_nk ON
    ebs_fcr_prod_ft_item (
        ebs_fcr_prod_filetype_id
    ASC,
        action_type
    ASC,
        item_filename
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_fcr_prod_ft_item ADD CONSTRAINT ebs_fcr_prod_ft_item_pk PRIMARY KEY ( id );

ALTER TABLE ebs_fcr_prod_ft_item
    ADD CONSTRAINT ebs_fcr_prod_ft_item_nk UNIQUE ( ebs_fcr_prod_filetype_id,
                                                    action_type,
                                                    item_filename );

CREATE TABLE ebs_fcr_product (
    id                INTEGER NOT NULL,
    ebs_fcr_src_id    INTEGER NOT NULL,
    ebs_product_id    INTEGER NOT NULL,
    ebs_product_code  VARCHAR2(128) NOT NULL,
    num_added         INTEGER,
    num_removed       INTEGER,
    num_stubbed       INTEGER,
    num_changed       INTEGER,
    num_unchanged     INTEGER
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_product_pk ON
    ebs_fcr_product (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_fcr_product_nk ON
    ebs_fcr_product (
        ebs_fcr_src_id
    ASC,
        ebs_product_id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_fcr_product_i1 ON
    ebs_fcr_product (
        ebs_fcr_src_id
    ASC,
        ebs_product_code
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_fcr_product ADD CONSTRAINT ebs_fcr_product_pk PRIMARY KEY ( id );

ALTER TABLE ebs_fcr_product ADD CONSTRAINT ebs_fcr_product_nk UNIQUE ( ebs_fcr_src_id,
                                                                       ebs_product_id );

CREATE TABLE ebs_fcr_src (
    id                  INTEGER NOT NULL,
    ebs_fcr_id          INTEGER NOT NULL,
    src_ebs_version_id  INTEGER NOT NULL,
    src_ebs_version     VARCHAR2(128) NOT NULL
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_fcr_src_pk ON
    ebs_fcr_src (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE INDEX ebs_fcr_src_fk ON
    ebs_fcr_src (
        src_ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_fcr_src ADD CONSTRAINT ebs_fcr_src_pk PRIMARY KEY ( id );

ALTER TABLE ebs_fcr_src ADD CONSTRAINT ebs_fcr_src_nk UNIQUE ( ebs_fcr_id,
                                                               src_ebs_version_id );

CREATE TABLE ebs_product (
    id                       INTEGER NOT NULL,
    ebs_version_id           INTEGER NOT NULL,
    ebs_product_code         VARCHAR2(128) NOT NULL,
    ebs_product_description  VARCHAR2(1024),
    ebs_family_id            INTEGER,
    striped                  VARCHAR2(32)
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_product_nk ON
    ebs_product (
        ebs_version_id
    ASC,
        ebs_product_code
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_product ADD CONSTRAINT ebs_product_pk PRIMARY KEY ( id );

ALTER TABLE ebs_product ADD CONSTRAINT ebs_product_nk UNIQUE ( ebs_version_id,
                                                               ebs_product_code );

CREATE TABLE ebs_sdcr (
    id                 INTEGER NOT NULL,
    ebs_version_id     INTEGER NOT NULL,
    ebs_version        VARCHAR2(128) NOT NULL,
    ebs_sdcr_dir_name  VARCHAR2(1024),
    date_generated     DATE,
    parser_version     VARCHAR2(128),
    parse_startdate    DATE,
    parse_enddate      DATE
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_pk ON
    ebs_sdcr (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_nk ON
    ebs_sdcr (
        ebs_version
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_fk ON
    ebs_sdcr (
        ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr ADD CONSTRAINT ebs_sdcr_pk PRIMARY KEY ( id );

ALTER TABLE ebs_sdcr ADD CONSTRAINT ebs_sdcr_nk UNIQUE ( ebs_version );

ALTER TABLE ebs_sdcr ADD CONSTRAINT ebs_sdcr_fk UNIQUE ( ebs_version_id );

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
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_dn_item_pk ON
    ebs_sdcr_dn_item (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr_dn_item ADD CONSTRAINT ebs_sdcr_dn_item_pk PRIMARY KEY ( id );

CREATE TABLE ebs_sdcr_dn_item_line (
    id                   INTEGER NOT NULL,
    ebs_sdcr_dn_item_id  INTEGER NOT NULL,
    trg_src              VARCHAR2(128) NOT NULL,
    line_no              INTEGER NOT NULL,
    status               VARCHAR2(128),
    line_text            CLOB
)
LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_dn_item_line_pk ON
    ebs_sdcr_dn_item_line (
        id
    ASC )
        LOGGING;

CREATE INDEX ebs_sdcr_dn_item_line_fk ON
    ebs_sdcr_dn_item_line (
        ebs_sdcr_dn_item_id
    ASC )
        LOGGING;

ALTER TABLE ebs_sdcr_dn_item_line ADD CONSTRAINT ebs_sdcr_dn_item_line_pk PRIMARY KEY ( id );

CREATE TABLE ebs_sdcr_item_line (
    id                        INTEGER NOT NULL,
    ebs_sdcr_prod_dt_item_id  INTEGER NOT NULL,
    trg_src                   VARCHAR2(128) NOT NULL,
    line_no                   INTEGER NOT NULL,
    status                    VARCHAR2(128) NOT NULL,
    line_text                 CLOB
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_item_line_pk ON
    ebs_sdcr_item_line (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_item_line_nk ON
    ebs_sdcr_item_line (
        ebs_sdcr_prod_dt_item_id
    ASC,
        trg_src
    ASC,
        line_no
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr_item_line ADD CONSTRAINT ebs_sdcr_item_line_pk PRIMARY KEY ( id );

ALTER TABLE ebs_sdcr_item_line
    ADD CONSTRAINT ebs_sdcr_item_line_nk UNIQUE ( ebs_sdcr_prod_dt_item_id,
                                                  trg_src,
                                                  line_no );

CREATE TABLE ebs_sdcr_prod_datatype (
    id                    INTEGER NOT NULL,
    ebs_sdcr_product_id   INTEGER NOT NULL,
    datatype_label        VARCHAR2(128) NOT NULL,
    datatype_description  VARCHAR2(1024),
    num_added             INTEGER,
    num_removed           INTEGER,
    num_changed           INTEGER
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_prod_datatype_pk ON
    ebs_sdcr_prod_datatype (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_prod_datatype_nk ON
    ebs_sdcr_prod_datatype (
        ebs_sdcr_product_id
    ASC,
        datatype_label
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr_prod_datatype ADD CONSTRAINT ebs_sdcr_prod_datatype_pk PRIMARY KEY ( id );

ALTER TABLE ebs_sdcr_prod_datatype ADD CONSTRAINT ebs_sdcr_prod_datatype_nk UNIQUE ( ebs_sdcr_product_id,
                                                                                     datatype_label );

CREATE TABLE ebs_sdcr_prod_dt_item (
    id                         INTEGER NOT NULL,
    ebs_sdcr_prod_datatype_id  INTEGER NOT NULL,
    action_type                VARCHAR2(128) NOT NULL,
    item_object_type           VARCHAR2(128) NOT NULL,
    item_product_code          VARCHAR2(128) NOT NULL,
    item_object_name           VARCHAR2(1024) NOT NULL,
    bookmark                   VARCHAR2(128)
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_prod_dt_item_pk ON
    ebs_sdcr_prod_dt_item (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_prod_dt_item_nk ON
    ebs_sdcr_prod_dt_item (
        ebs_sdcr_prod_datatype_id
    ASC,
        action_type
    ASC,
        item_object_type
    ASC,
        item_product_code
    ASC,
        item_object_name
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr_prod_dt_item ADD CONSTRAINT ebs_sdcr_prod_dt_item_pk PRIMARY KEY ( id );

ALTER TABLE ebs_sdcr_prod_dt_item
    ADD CONSTRAINT ebs_sdcr_prod_dt_item_nk UNIQUE ( ebs_sdcr_prod_datatype_id,
                                                     action_type,
                                                     item_object_type,
                                                     item_product_code,
                                                     item_object_name );

CREATE TABLE ebs_sdcr_product (
    id                INTEGER NOT NULL,
    ebs_sdcr_src_id   INTEGER NOT NULL,
    ebs_product_id    INTEGER NOT NULL,
    ebs_product_code  VARCHAR2(128) NOT NULL,
    num_added         INTEGER,
    num_removed       INTEGER,
    num_changed       INTEGER
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_product_pk ON
    ebs_sdcr_product (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_product_nk ON
    ebs_sdcr_product (
        ebs_sdcr_src_id
    ASC,
        ebs_product_id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_product_i1 ON
    ebs_sdcr_product (
        ebs_sdcr_src_id
    ASC,
        ebs_product_code
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr_product ADD CONSTRAINT ebs_sdcr_product_pk PRIMARY KEY ( id );

ALTER TABLE ebs_sdcr_product ADD CONSTRAINT ebs_sdcr_product_nk UNIQUE ( ebs_sdcr_src_id,
                                                                         ebs_product_id );

CREATE TABLE ebs_sdcr_src (
    id                  INTEGER NOT NULL,
    ebs_sdcr_id         INTEGER NOT NULL,
    src_ebs_version_id  INTEGER NOT NULL,
    src_ebs_version     VARCHAR2(128) NOT NULL
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_src_pk ON
    ebs_sdcr_src (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_sdcr_src_nk ON
    ebs_sdcr_src (
        ebs_sdcr_id
    ASC,
        src_ebs_version_id
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_sdcr_src ADD CONSTRAINT ebs_sdcr_src_pk PRIMARY KEY ( id );

ALTER TABLE ebs_sdcr_src ADD CONSTRAINT ebs_sdcr_src_nk UNIQUE ( ebs_sdcr_id,
                                                                 src_ebs_version_id );

CREATE TABLE ebs_version (
    id                       INTEGER NOT NULL,
    ebs_version_label        VARCHAR2(128) NOT NULL,
    ebs_version_short_label  VARCHAR2(128),
    ebs_version_fcr_label    VARCHAR2(128),
    ebs_version_description  VARCHAR2(1024)
)
TABLESPACE ringmd LOGGING;

CREATE UNIQUE INDEX ebs_version_pk ON
    ebs_version (
        id
    ASC )
        TABLESPACE ringmx LOGGING;

CREATE UNIQUE INDEX ebs_version_nk ON
    ebs_version (
        ebs_version_label
    ASC )
        TABLESPACE ringmx LOGGING;

ALTER TABLE ebs_version ADD CONSTRAINT ebs_version_pk PRIMARY KEY ( id );

ALTER TABLE ebs_version ADD CONSTRAINT ebs_version_nk UNIQUE ( ebs_version_label );

ALTER TABLE ebs_dmcr_dn_object_text
    ADD CONSTRAINT ebs_dmcr_dn_text_2_object_fk FOREIGN KEY ( ebs_dmcr_dn_object_id )
        REFERENCES ebs_dmcr_dn_object ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_dmcr_object
    ADD CONSTRAINT ebs_dmcr_object_2_product_fk FOREIGN KEY ( ebs_dmcr_product_id )
        REFERENCES ebs_dmcr_product ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_dmcr_product
    ADD CONSTRAINT ebs_dmcr_product_2_dmcr_fk FOREIGN KEY ( ebs_dmcr_id )
        REFERENCES ebs_dmcr ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_dmcr_product
    ADD CONSTRAINT ebs_dmcr_product_2_product_fk FOREIGN KEY ( ebs_product_id )
        REFERENCES ebs_product ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_dmcr
    ADD CONSTRAINT ebs_dmcr_src_2_version_fk FOREIGN KEY ( src_ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_dmcr_text
    ADD CONSTRAINT ebs_dmcr_text_2_object_fk FOREIGN KEY ( ebs_dmcr_object_id )
        REFERENCES ebs_dmcr_object ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_dmcr
    ADD CONSTRAINT ebs_dmcr_trg_2_version_fk FOREIGN KEY ( trg_ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_family
    ADD CONSTRAINT ebs_family_2_version_fk FOREIGN KEY ( ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_dn_item_line
    ADD CONSTRAINT ebs_fcr_dn_item_2_item_fk FOREIGN KEY ( ebs_fcr_dn_item_id )
        REFERENCES ebs_fcr_dn_item ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr
    ADD CONSTRAINT ebs_fcr_ebs_version_fk FOREIGN KEY ( ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_ft_item_line
    ADD CONSTRAINT ebs_fcr_ft_item_line_2_item_fk FOREIGN KEY ( ebs_fcr_prod_ft_item_id )
        REFERENCES ebs_fcr_prod_ft_item ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_prod_filetype
    ADD CONSTRAINT ebs_fcr_prod_ft_2_prod_fk FOREIGN KEY ( ebs_fcr_product_id )
        REFERENCES ebs_fcr_product ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_prod_ft_item
    ADD CONSTRAINT ebs_fcr_prod_ft_item_2_ft_fk FOREIGN KEY ( ebs_fcr_prod_filetype_id )
        REFERENCES ebs_fcr_prod_filetype ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_product
    ADD CONSTRAINT ebs_fcr_product_2_fcr_src_fk FOREIGN KEY ( ebs_fcr_src_id )
        REFERENCES ebs_fcr_src ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_product
    ADD CONSTRAINT ebs_fcr_product_2_product_fk FOREIGN KEY ( ebs_product_id )
        REFERENCES ebs_product ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_src
    ADD CONSTRAINT ebs_fcr_src_ebs_fcr_fk FOREIGN KEY ( ebs_fcr_id )
        REFERENCES ebs_fcr ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_fcr_src
    ADD CONSTRAINT ebs_fcr_src_ebs_version_fk FOREIGN KEY ( src_ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_product
    ADD CONSTRAINT ebs_product_2_family_fk FOREIGN KEY ( ebs_family_id )
        REFERENCES ebs_family ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_product
    ADD CONSTRAINT ebs_product_2_version_fk FOREIGN KEY ( ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr
    ADD CONSTRAINT ebs_sdcr_2_version_fk FOREIGN KEY ( ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_dn_item_line
    ADD CONSTRAINT ebs_sdcr_dn_line_2_item_fk FOREIGN KEY ( ebs_sdcr_dn_item_id )
        REFERENCES ebs_sdcr_dn_item ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_item_line
    ADD CONSTRAINT ebs_sdcr_item_line_2_item_fk FOREIGN KEY ( ebs_sdcr_prod_dt_item_id )
        REFERENCES ebs_sdcr_prod_dt_item ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_prod_datatype
    ADD CONSTRAINT ebs_sdcr_prod_dt_2_product_fk FOREIGN KEY ( ebs_sdcr_product_id )
        REFERENCES ebs_sdcr_product ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_prod_dt_item
    ADD CONSTRAINT ebs_sdcr_prod_dt_item_2_dt_fk FOREIGN KEY ( ebs_sdcr_prod_datatype_id )
        REFERENCES ebs_sdcr_prod_datatype ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_product
    ADD CONSTRAINT ebs_sdcr_product_2_product_fk FOREIGN KEY ( ebs_product_id )
        REFERENCES ebs_product ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_product
    ADD CONSTRAINT ebs_sdcr_product_2_src_fk FOREIGN KEY ( ebs_sdcr_src_id )
        REFERENCES ebs_sdcr_src ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_src
    ADD CONSTRAINT ebs_sdcr_src_2_report_fk FOREIGN KEY ( ebs_sdcr_id )
        REFERENCES ebs_sdcr ( id )
    NOT DEFERRABLE;

ALTER TABLE ebs_sdcr_src
    ADD CONSTRAINT ebs_sdcr_src_2_version_fk FOREIGN KEY ( src_ebs_version_id )
        REFERENCES ebs_version ( id )
    NOT DEFERRABLE;

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
-- CREATE TABLE                            25
-- CREATE INDEX                            53
-- ALTER TABLE                             75
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
-- CREATE SEQUENCE                         19
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