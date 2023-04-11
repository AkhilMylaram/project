Oracle EBS Comparison Report: Metadata Extraction and Denormalization 
======================================================================
Version: 1.0


Purpose:
========
To extract the Metadata from Oracle's EBS Comparison Reports and export them as denormalized tables.  The denormalized data is to be used to identify impacted objects when upgrading from a source EBS version to a target EBS version.


Background:
===========
Oracle has provided EBS Comparison Reports for the following EBS objects:
1. Data Model Objects
2. Seed Data Objects
3. File Objects
Following are the links to the Oracle Blog announcing the reports and to the MOS documents containing the reports:

Steven Chan Blog: EBS Seed Data Comparison Report
https://blogs.oracle.com/ebstech/ebs-seed-data-comparison-reports-now-available
MOS Document:
https://metalink.oracle.com/metalink/plsql/showdoc?db=NOT&id=1327399.1

Steven Chan Blog: Data Model Changes Report
https://blogs.oracle.com/ebstech/identifying-data-model-changes-between-ebs-1213-and-prior-ebs-releases
MOS Document:
https://metalink.oracle.com/metalink/plsql/showdoc?db=NOT&id=1290886.1

Steven Chan Blog: File Comparison Report
https://blogs.oracle.com/ebstech/ebs-file-comparison-report-now-available
MOS Document:
https://metalink.oracle.com/metalink/plsql/showdoc?db=NOT&id=1446430.1


Contents:
=========
1. ERD diagram with all the supporting tables for the extracted matadata and denormalized tables.  Includes indexes and sequences.
2. DDL scripts to create tables, indexes and sequences.
3. Python scripts to extract the Metadata from the reports, driven by CSV input files
4. List of EBS versions in CSV format
5. List of input directories with the Comparison Reports in CSV format
6. Downloaded Comparison Reports in ZIP format


Pre-requisites
==============
1. Oracle RDBMS 11gR2 or higher
2. Oracle client (if not included in the RDBMS)
3. Python 3, latest release
4. cx_Oracle python module
5. Create the schema owner in a database 11gR2 or higher.  
   - Create a tablespace named RINGMD, 15 GB for each TARGET EBS version you plan to load
   - Create a tablespace named RINGMX,  5 GB for each TARGET EBS version you plan to load


Initial preparation before extract:
===================================
The steps to follow to extract the metadata and export the denormalized data:
1. Pull the code from the git repository.
   https://git-codecommit.us-east-2.amazonaws.com/v1/repos/RingMaster-Studio-Upgrade-Assistant
   You will need Git credentials from the RingMaster Studio product manager
   Subdirectory location: OracleComparisonReport
2. Pull the Comparison Reports ZIP files from the git repository.
   https://git-codecommit.us-east-2.amazonaws.com/v1/repos/RingMasterStudio-Common
   You will need Git credentials from the RingMaster Studio product manager
   Subdirectory location: repository/seeddata_source/ebs_comparison
3. Create the schema to store the metadata.  Script to run:
   - schema-tables-constraints-fks-indexes-sequences.ddl
   **NOTE**: You only need to do this ONCE


Process Overview to extract Metadata:
=====================================
1. Unzip the desired Comparison Reports under the ebs_comparison directory.  For each report:
   - Data Model report: ebs_comparison/EBS_DataModel_Comparison/<TARGET_EBS_VERSION>/
   - Seed Data  report: ebs_comparison/EBS_Seed_Data_Comparison/<TARGET_EBS_VERSION>/
   - File Comparison  : ebs_comparison/EBS_File_Comparison/<TARGET_EBS_VERSION>/
2. Define the list of EBS reports you wish to process.  The files to edit:
   - ebs_dmcr_reports.csv : List of Data Model reports
   - ebs_fcr_reports.csv  : List of File Objects reports
   - ebs_sdcr_reports.csv : List of Seed Data reports
   *NOTE*: Do not remove the header line.  To comment out a row, use the # (hash) symbol at the beginning of the line.
3. Define the RDBMS credentials in the rdbms_creds.py script
4. Source the Oracle client/server libraries
5. Run the python script:
   sh -x r
6. If there are any issues, resolve them and rerun the script:
   sh -x r 


Process Overview to denormalize data:
=====================================
1. Source the Oracle library
2. Run the denormalization script.  You will need to indicate the SOURCE and TARGET EBS versions you want to denormalize.
   - sh denormalize.sh <SOURCE EBS Version> <TARGET EBS Version>
   *NOTE*: Follow the EBS version labels as found in the ebs_versions.csv file, column "ebs_version_label"
3. Using SQLDeveloper, export the data into INSERT statements.  Run the following script on SQLDeveloper:
   - export_dn_inserts.sql
4. Process the INSERT scripts and package into ZIP file
   - sh package.sh <SOURCE EBS Version> <TARGET EBS Version>
   *NOTE*: Follow the EBS version labels as found in the ebs_versions.csv file, column "ebs_version_label"
