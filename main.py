# -*- coding: utf-8 -*-
"""
Created on Mon Feb 24 16:59:04 2020

@author: Walter-Montalvo
"""

from schema_ebs_core import *

from schema_ebs_sdcr import *
from scrape_ebs_sdcr import *

from schema_ebs_fcr  import *
from scrape_ebs_fcr  import *

from schema_ebs_dmcr import *
from scrape_ebs_dmcr import *

import csv
import traceback
import sys
from dao import  *


# Read seeded list of ebs versions

# NOTE: Report from:
# https://blogs.oracle.com/ebstech/ebs-file-comparison-report-now-available

csv_ebs_versions= []
with open("ebs_versions.csv", "r") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        csv_ebs_versions.append(row)
#print(csv_ebs_versions)


ebs_sdcr_reports= []
with open("ebs_sdcr_reports.csv", "r") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        ebs_sdcr_reports.append(row)
#print(ebs_sdcr_reports)

ebs_fcr_reports= []
with open("ebs_fcr_reports.csv", "r") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        ebs_fcr_reports.append(row)
#print(ebs_fcr_reports)

ebs_dmcr_reports= []
with open("ebs_dmcr_reports.csv", "r") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        ebs_dmcr_reports.append(row)
#print(ebs_dmcr_reports)


# Establish connection to DBMS

try:
    dao.connect()
except Exception:
    print("ERROR: Unable to connect to RDBMS")
    print(traceback.format_exc())
    dao.disconnect()
    sys.exit()

# Insert list of ebs_versions and parse reports

list_ebs_versions = []
try:

    for csv_ebs_version in csv_ebs_versions:
        ebs_version = dao_ebs_version()
        ebs_version.ebs_version_label = csv_ebs_version["ebs_version_label"]
        ebs_version.ebs_version_short_label = csv_ebs_version["ebs_version_short_label"]
        ebs_version.ebs_version_fcr_label = csv_ebs_version["ebs_version_fcr_label"]
        ebs_version.ebs_version_description = csv_ebs_version["ebs_version_description"]
        list_ebs_versions.append(ebs_version)

        # Load seeded data
        ebs_version.upsert()
        ebs_version.add_all_product()
        dao.connection.commit()

    for ebs_sdcr_report in ebs_sdcr_reports:
        if (ebs_sdcr_report["ebs_sdcr_dir_name"].startswith('#')):
            continue
        print("SDCR Scraping: " + ebs_sdcr_report["ebs_sdcr_dir_name"])
        scraper = ebs_sdcr_scraper(ebs_sdcr_report, list_ebs_versions)
        scraper.parse_report()
        dao.connection.commit()

    for ebs_fcr_report in ebs_fcr_reports:
        if (ebs_fcr_report["ebs_fcr_dir_name"].startswith('#')):
            continue
        print("FCR  Scraping: " + ebs_fcr_report["ebs_fcr_dir_name"])
        scraper = ebs_fcr_scraper(ebs_fcr_report, list_ebs_versions)
        scraper.parse_report()
        dao.connection.commit()

    for ebs_dmcr_report in ebs_dmcr_reports:
        if (ebs_dmcr_report["ebs_dmcr_dir_name"].startswith('#')):
            continue
        print("DMCR Scraping: " + ebs_dmcr_report["ebs_dmcr_dir_name"])
        scraper = ebs_dmcr_scraper(ebs_dmcr_report, list_ebs_versions)
        scraper.parse_report()
        dao.connection.commit()

    dao.connection.commit()

except Exception:
    print(traceback.format_exc())
    dao.disconnect()

dao.disconnect()
