Oracle Comparison Report Metadata
Denormalized tables
version: 1.0

Purpose:
Procedure to import the extracted and denormalized Oracle Comparison Report Metadata into a customer's EBS repository.
There will be six tables created to store the extracted metadata.  You have two levels of detail when doing an import:
1. Import the list of impacted objects, *without* the text lines.  This will give you for each object its status of whether it was added, removed or changed between EBS versions.
2. Import the list of impacted objects, with the text lines.  In addition to the list of objects and status, you will get the list of text lines compared between the EBS versions.

Resources before import:
1. (OPTIONAL): Create a new schema to store denormalized tables.  You can skip this if you will be importing into an existing schema.
2. (OPTIONAL) On the target database, create the RINGMD and RINGMX tablespaces.  You should allocate 5 GB for RINGMD and 2 GB for RINGMX.
3. If you decided NOT to create the tablespaces above, you will need to modify a couple DDL scripts and change the TABLESPACE clause as follows:
- for schema-dn-tables.ddl - change the TABLESPACE name to the correct one
- for schema-dn-indexes-constraints.ddl - change the TABLESPACE name to the correct one

Preparation if importing for the first time:
1. Create the tables.  Using sqlplus run:
@schema-dn-tables.ddl

Preparation if appending to an existing set of denormalized tables (so adding multiple combinations of SOURCE and TARGET EBS Versions):
1. Drop indexes and constraints:
@schema-dn-drop-indexes-constraints.ddl

Import data:
1. Load the list of impacted objects.  Using sqlplus, run:
@export_dn_commit.sql
2. (OPTIONAL): Load the list of text lines for the impacted objects.  Using sqlplus, run:
@export_dn_text_commit.sql
3. Create the indexes and constraints.  Using sqlplus, run:
@schema-dn-indexes-constraints.ddl


