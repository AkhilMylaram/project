# -*- coding: utf-8 -*-
"""
Created on Tue Mar 10 13:40:03 2020

@author: Walter-Montalvo
"""

from bs4 import BeautifulSoup
from schema_ebs_core import *
from schema_ebs_fcr  import *

import datetime

"""

HTML Hierarchy

<REPORT_DIR>/Data/header.html
List of src_ebs_version
ebs_version_label
List of ebs_family
ebs_family_code
ebs_family_name

ebs_fcr
-------
ebs_version

ebs_fcr_src
------------
src_ebs_version


<REPORT_DIR>/Data/<EBS_FAMILY_LABEL>_<TRG_EBS_LABEL>_<SRC_EBS_LABEL>/index.html

List of products for EBS_FAMILY_LABEL, with statistics
ebs_product
-----------
ebs_product_code
ebs_product_description

ebs_fcr_product
---------------
ebs_product_code
num_added
num_removed
num_stubbed
num_changed
num_unchanged


<REPORT_DIR>/Data/<EBS_FAMILY_LABEL>_<TRG_EBS_LABEL>_<SRC_EBS_LABEL>/<EBS_PRODUCT_CODE>_diff_report.html

List of filetypes for EBS_PRODUCT_CODE and statistics

ebs_fcr_prod_filetype
---------------------
filetype_label
filetype_description
num_added
num_removed
num_stubbed
num_changed
num_unchanged


<REPORT_DIR>/Data/<EBS_FAMILY_LABEL>_<TRG_EBS_LABEL>_<SRC_EBS_LABEL>/<FILETYPE_LABEL>.<EBS_PRODUCT_CODE>.html

List of filetype items for EBS_PRODUCT_CODE and FILETYPE_LABEL.  

ebs_fcr_prod_ft_item
--------------------
action_type
item_filename
item_version
item_src_version
item_comparison_html_path
list 

<REPORT_DIR>/Data/<EBS_FAMILY_LABEL>_<TRG_EBS_LABEL>_<SRC_EBS_LABEL>/diff/<item_comparison_html_path>

Difference report for CHANGED item between trg_filetype_item and src_filetype_item

ebs_fcr_ft_item_line
--------------------
line_no
trg_line_no
trg_status
trg_text
src_line_no
src_status
src_text


"""

class ebs_fcr_scraper:

    def __init__(self, ebs_fcr_report, list_ebs_version):
        self.ebs_fcr_dir_name = ebs_fcr_report["ebs_fcr_dir_name"]
        self.list_ebs_version = list_ebs_version
        self.ebs_version = self.get_ebs_version_by_label(ebs_fcr_report["ebs_version_label"])
        self.parser_version = "1.1"
    
    
    def parse_report(self):
        # Extract list of family codes, 
        # populate:
        # ebs_version.ebs_fcr
        # ebs_version.list_ebs_family,
        self.parse_header() 
        dao.connection.commit()
        for ebs_fcr_src in self.ebs_version.ebs_fcr.list_ebs_fcr_src:
            print("  SRC_EBS_VERSION: " + ebs_fcr_src.src_ebs_version)
            #if ( ebs_fcr_src.src_ebs_version != "12.1.3" ): # TEST CODE
            #    continue
            for ebs_family in self.ebs_version.list_ebs_family:
                print("    Family: " + ebs_family.ebs_family_code)
                # Extract list of products for src_ebs and ebs_family
                self.parse_index(ebs_fcr_src, ebs_family)
                dao.connection.commit()
            for ebs_fcr_product in ebs_fcr_src.list_ebs_fcr_product:
                print("      Product: " + ebs_fcr_product.ebs_product_code)
                #if ( ebs_fcr_product.ebs_product_code != "AD" ): # TEST CODE
                #    continue
                # Extract list of filetypes 
                ebs_family = self.get_ebs_family_by_ebs_product_code(ebs_fcr_product.ebs_product_code)
                self.parse_diff_report(ebs_fcr_src, ebs_family, ebs_fcr_product)
                dao.connection.commit()
                for ebs_fcr_prod_filetype in ebs_fcr_product.list_ebs_fcr_prod_filetype:
                    print("        Filetype: " + ebs_fcr_prod_filetype.filetype_label)
                    # Extract list of filetype items
                    self.parse_filetype_item(ebs_fcr_src, ebs_family, ebs_fcr_product, ebs_fcr_prod_filetype)
                    dao.connection.commit()
                    for ebs_fcr_prod_ft_item in ebs_fcr_prod_filetype.list_ebs_fcr_prod_ft_item:
                        if ( ebs_fcr_prod_ft_item.action_type == "Changed" ):
                            print("          Item Changed: " + ebs_fcr_prod_ft_item.item_filename)
                            # Extract differences for filetype item
                            # TEST SKIP CODE self.parse_diff_item(ebs_fcr_src, ebs_family, ebs_fcr_product, ebs_fcr_prod_filetype, ebs_fcr_prod_ft_item)
                            self.parse_diff_item(ebs_fcr_src, ebs_family, ebs_fcr_product, ebs_fcr_prod_filetype, ebs_fcr_prod_ft_item)
                            dao.connection.commit()
                        ebs_fcr_prod_ft_item = None
                    ebs_fcr_prod_filetype.list_ebs_fcr_prod_ft_item = []
                ebs_fcr_product.list_ebs_fcr_prod_filetype = []
            ebs_fcr_src.list_ebs_fcr_product = []
        ebs_fcr = self.ebs_version.ebs_fcr
        ebs_fcr.parse_enddate     = datetime.datetime.now()
        ebs_fcr.upsert()
        dao.connection.commit()



    def parse_header(self):
        ebs_fcr = dao_ebs_fcr()
        ebs_fcr.ebs_version_id   = self.ebs_version.id
        ebs_fcr.ebs_version      = self.ebs_version.ebs_version_label
        ebs_fcr.ebs_fcr_dir_name = self.ebs_fcr_dir_name
        ebs_fcr.parser_version   = self.parser_version
        ebs_fcr.parse_startdate  = datetime.datetime.now()
        ebs_fcr.parse_enddate    = None

        self.ebs_version.ebs_fcr = ebs_fcr
        ebs_fcr.upsert() 
        
        soup = self.html_parser(ebs_fcr.ebs_fcr_dir_name + 
                                "/Data/header.html")
        
        list_ebs_family = []
        family_select = soup.find(id="rup")
        family_options = family_select.find_all("option")
        for family_option in family_options:
            ebs_family = dao_ebs_family()
            ebs_family.ebs_version_id = self.ebs_version.id
            ebs_family.ebs_family_code = family_option.get('value')
            ebs_family.ebs_family_description = family_option.get_text().replace(u'\xa0', u' ')
            self.ebs_version.list_ebs_family.append(ebs_family)
            ebs_family.upsert()
        
        # Extract list of src_ebs_versions
        # Populate ebs_fcr.list_ebs_fcr_src
        list_ebs_fcr_src = []
        src_ebs_version_select = soup.find(id="rel")
        src_ebs_version_options = src_ebs_version_select.find_all("option")
        for src_ebs_version_option in src_ebs_version_options:
            trg_src_value = src_ebs_version_option.get('value')
            src_ebs_version_short_label = trg_src_value.split('_')[1]
            #print(src_ebs_version)
            ebs_fcr_src = dao_ebs_fcr_src()
            ebs_fcr_src.ebs_fcr_id = self.ebs_version.ebs_fcr.id
            src_ebs_version = self.get_ebs_version_by_short_label(src_ebs_version_short_label)
            ebs_fcr_src.src_ebs_version_id = src_ebs_version.id
            ebs_fcr_src.src_ebs_version    = src_ebs_version.ebs_version_label
            ebs_fcr_src.list_ebs_fcr_product = []
            ebs_fcr_src.upsert()
            list_ebs_fcr_src.append(ebs_fcr_src)
        self.ebs_version.ebs_fcr.list_ebs_fcr_src = list_ebs_fcr_src
        
        
    def parse_index(self, ebs_fcr_src, ebs_family):
        src_ebs_version = self.get_ebs_version_by_label(ebs_fcr_src.src_ebs_version)
        soup = self.html_parser(self.ebs_fcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code + 
                                "_" + 
                                self.ebs_version.ebs_version_short_label + 
                                "_" + 
                                src_ebs_version.ebs_version_short_label + 
                                "/index.html")
        
        # Extract list of products, and stats 
        # Populate:
        # ebs_family.list_ebs_product, 
        # ebs_fcr_src.list_ebs_fcr_product
        list_ebs_product = []
        for tr in soup.find("table").find_all("tr"):
            td = tr.find("td")
            if ( td == None ):
                continue
            atag = td.find("a")
            ebs_product_code = atag.get_text()
            #print ("--> ebs_product_code: " + ebs_product_code)
            ebs_product_description = atag.get("title")
            ebs_product = dao_ebs_product()
            ebs_product.ebs_version_id = self.ebs_version.id
            ebs_product.ebs_product_code = ebs_product_code
            ebs_product.ebs_product_description = ebs_product_description
            ebs_product.ebs_family_id = ebs_family.id
            ebs_product.striped = "STRIPED"
            ebs_product.upsert()
            list_ebs_product.append(ebs_product)
            list_tds = tr.find_all('td')
            ebs_fcr_product = dao_ebs_fcr_product()
            ebs_fcr_product.ebs_fcr_src_id  = ebs_fcr_src.id
            ebs_fcr_product.ebs_product_id   = ebs_product.id
            ebs_fcr_product.ebs_product_code = ebs_product.ebs_product_code
            ebs_fcr_product.num_added        = self.to_int(list_tds[1].get_text())
            ebs_fcr_product.num_removed      = self.to_int(list_tds[2].get_text())
            ebs_fcr_product.num_stubbed      = self.to_int(list_tds[3].get_text())
            ebs_fcr_product.num_changed      = self.to_int(list_tds[4].get_text())
            ebs_fcr_product.num_unchanged    = self.to_int(list_tds[5].get_text())
            #print("-->ebs_fcr_product.ebs_product_code: " + ebs_fcr_product.ebs_product_code)
            ebs_fcr_product.upsert()
            ebs_fcr_src.list_ebs_fcr_product.append(ebs_fcr_product)
            #print("col cell: " +ebs_family.ebs_family_code + "," + ebs_product_code + ":" + list_tds[idx+1].get_text() + ":" + list_tds[idx+2].get_text() + ":" + list_tds[idx+3].get_text() + ":")
        ebs_fcr_src.list_ebs_product = list_ebs_product
        ebs_family.list_ebs_product = list_ebs_product

    
    
    def parse_diff_report(self, ebs_fcr_src, ebs_family, ebs_fcr_product):
        # Extract filetype metadata and stats
        # Populate:
        # ebs_fcr_product.list_ebs_fcr_prod_dfiletype
        src_ebs_version = self.get_ebs_version_by_label(ebs_fcr_src.src_ebs_version)
        soup = self.html_parser(self.ebs_fcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code.upper() + 
                                "_" + 
                                self.ebs_version.ebs_version_short_label + 
                                "_" + 
                                src_ebs_version.ebs_version_short_label + 
                                "/" + 
                                ebs_fcr_product.ebs_product_code + 
                                "_diff_report.html")
        
        list_tr = soup.find_all('tr')
        ebs_fcr_product.list_ebs_fcr_prod_filetype = []
        for tr in list_tr:
            list_td = tr.find_all('td')
            if ( list_td == [] ):
                continue
            atag = list_td[0].find('a')
            if ( atag == None ):
                continue
            ahref = atag.get('href')
            atexts = ahref.split("'")
            ebs_product_code          = atexts[1]
            src_ebs_version_fcr_label = atexts[3].split('-')[1]
            filetype_label            = atexts[5]
            filetype_description      = atag.get_text()
            if ( src_ebs_version_fcr_label != src_ebs_version.ebs_version_fcr_label or ebs_product_code != ebs_fcr_product.ebs_product_code ):
                continue
            ebs_fcr_prod_filetype = dao_ebs_fcr_prod_filetype()
            ebs_fcr_prod_filetype.ebs_fcr_product_id   = ebs_fcr_product.id
            ebs_fcr_prod_filetype.filetype_label       = filetype_label
            ebs_fcr_prod_filetype.filetype_description = filetype_description
            ebs_fcr_prod_filetype.num_added            = self.to_int(list_td[1].get_text())
            ebs_fcr_prod_filetype.num_removed          = self.to_int(list_td[2].get_text())
            ebs_fcr_prod_filetype.num_stubbed          = self.to_int(list_td[3].get_text())
            ebs_fcr_prod_filetype.num_changed          = self.to_int(list_td[4].get_text())
            ebs_fcr_prod_filetype.num_unchanged        = self.to_int(list_td[5].get_text())
            ebs_fcr_product.list_ebs_fcr_prod_filetype.append(ebs_fcr_prod_filetype)
            #print("            [dt]: " + ebs_product_code + ":" + src_ebs_version + ":" + datatype_label + ":" + str(ebs_sdcr_prod_datatype.num_added)  + ":" + str(ebs_sdcr_prod_datatype.num_removed)  + ":" + str(ebs_sdcr_prod_datatype.num_changed) )
            ebs_fcr_prod_filetype.upsert()
    

    def parse_filetype_item(self, ebs_fcr_src, ebs_family, ebs_fcr_product, ebs_fcr_prod_filetype):
        # Extract list of items for filetype
        # populate
        # ebs_fcr_prod_filetype.list_ebs_fcr_prod_ft_item
        '''
        When parsing for ACTION_TYPE, the expected location is a <h2> with a <a> tage. 
        the <a> tage has a text of Added in ... or Changed in..
        For instance:
        <h2><a name="changed">Changed in 12.2.10</a></h2>
        However, on the 12.2.10 report, we find:
        <a name="added"></a>Added in 12.2.10</h2>
        The text is outside the <a> tag.  This means that:
        1. Perhaps the HTML report is formatted manually
        2. We need to look for the text in the <h2> instead
        We still need to find a <h2> tag that contains a <a> tag.  
        But the text should come from the <h2> tag
        NOTE: This seems to apply only to FILETYPE: Workflow_Definition_WFT
        '''
        src_ebs_version = self.get_ebs_version_by_label(ebs_fcr_src.src_ebs_version)
        print(self.ebs_fcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code.upper() + 
                                "_" + 
                                self.ebs_version.ebs_version_short_label + 
                                "_" + 
                                src_ebs_version.ebs_version_short_label + 
                                "/" + 
                                ebs_fcr_prod_filetype.filetype_label +
                                "." +
                                ebs_fcr_product.ebs_product_code + 
                                ".html")
        soup = self.html_parser(self.ebs_fcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code.upper() + 
                                "_" + 
                                self.ebs_version.ebs_version_short_label + 
                                "_" + 
                                src_ebs_version.ebs_version_short_label + 
                                "/" + 
                                ebs_fcr_prod_filetype.filetype_label +
                                "." +
                                ebs_fcr_product.ebs_product_code + 
                                ".html")

        node = soup.html.body.contents[0]
        in_block = None
        while ( node != None ):
            if ( node.name == "h2" ):
                print(node)
                in_block = None
                if ( node.a != None ):
                    if (   "Added"     in node.get_text() ):
                        in_block = "Added"
                    elif ( "Removed"   in node.get_text() ):
                        in_block = "Removed"
                    elif ( "Stubbed"   in node.get_text() ):
                        in_block = "Stubbed"
                    elif ( "Changed"   in node.get_text() ):
                        in_block = "Changed"
                    elif ( "Unchanged" in node.get_text() ):
                        in_block = "Unchanged"
            elif ( in_block != None ):
                if ( node.name == "table" ):
                    print(in_block)
                    print(node)
                    cnt_tr=0
                    for tr in node.find_all("tr"):
                        cnt_tr += 1
                        if ( cnt_tr == 1 ): #Skip first row
                            continue
                        tds = tr.find_all("td")
                        item_filename             = None
                        item_version              = None
                        item_src_version          = None
                        item_comparison_html_path = None
                        if ( in_block   == "Added" ):
                            item_filename             = tds[0].get_text()
                            item_version              = tds[1].get_text()
                        elif ( in_block == "Removed" ):
                            item_filename             = tds[0].get_text()
                            item_src_version          = tds[1].get_text()
                        elif ( in_block == "Stubbed" ):
                            item_filename             = tds[0].get_text()
                            item_version              = tds[1].get_text()
                            item_src_version          = tds[2].get_text()
                        elif ( in_block == "Changed" ):
                            item_comparison_html_path = tds[0].a.get('href')
                            item_filename             = tds[1].get_text()
                            item_version              = tds[2].get_text()
                            item_src_version          = tds[3].get_text()
                        elif ( in_block == "Unchanged" ):
                            item_filename             = tds[0].get_text()
                            item_version              = tds[1].get_text()
                            item_src_version          = tds[2].get_text()
                        print(ebs_fcr_prod_filetype.filetype_label
                           + "," +                     in_block
                           + "," +                     item_filename)
                        self.upsert_filetype_item(ebs_fcr_prod_filetype, 
                                                  in_block, 
                                                  item_filename,
                                                  item_version,
                                                  item_src_version,
                                                  item_comparison_html_path)
            node = node.nextSibling
    

    """
<REPORT_DIR>/Data/<EBS_FAMILY_LABEL>_<TRG_EBS_LABEL>_<SRC_EBS_LABEL>/diff/<item_comparison_html_path>

Difference report for CHANGED item between trg_filetype_item and src_filetype_item

ebs_fcr_ft_item_line
--------------------
line_no
trg_line_no
trg_status
trg_text
src_line_no
src_status
src_text

    """    
    
    def parse_diff_item(self, ebs_fcr_src, ebs_family, ebs_fcr_product, ebs_fcr_prod_filetype, ebs_fcr_prod_ft_item):
        # Extract list of text lines for item that has changed
        # Store trg and src lines side by side
        src_ebs_version = self.get_ebs_version_by_label(ebs_fcr_src.src_ebs_version)
        soup = self.html_parser(self.ebs_fcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code.upper() + 
                                "_" + 
                                self.ebs_version.ebs_version_short_label + 
                                "_" + 
                                src_ebs_version.ebs_version_short_label + 
                                "/" + 
                                ebs_fcr_prod_ft_item.item_comparison_html_path)
        
        main_table = None
        for table in soup.html.body.find_all("table"):
            if ( table.get("class")[0] == "maintab" ):
                main_table = table
                break
        
        line_no = -1
        for tr in main_table.find_all("tr"):
            line_no += 1
            if ( line_no == 0 ): # Skip header row
                continue
            tds = tr.find_all("td")
            if ( len(tds) != 2 ):
                continue
            (td_trg, td_src) = tds
            font_trg = td_trg.p.font
            font_src = td_src.p.font
            trg_line_no = None
            trg_status = td_trg.get("class")[0]
            trg_text = None
            src_line_no = None
            src_status = td_src.get("class")[0]
            src_text = None
            if ( font_trg != None ):
                font_str = font_trg.get_text()
                line_text = td_trg.get_text()
                trg_line_no = self.to_int(font_str)
                #trg_text = line_text.replace(font_str, '').replace(u'\xa0', u' ').replace(u'\u200b', u' ')
                trg_text = line_text.replace(font_str, '').encode('ascii', 'replace').decode('ascii')
            if ( font_src != None ):
                font_str = font_src.get_text()
                line_text = td_src.get_text()
                src_line_no = self.to_int(font_str)
                #src_text = line_text.replace(font_str, '').replace(u'\xa0', u' ').replace(u'\u200b', u' ')
                src_text = line_text.replace(font_str, '').encode('ascii', 'replace').decode('ascii')
            ebs_fcr_ft_item_line = dao_ebs_fcr_ft_item_line()
            ebs_fcr_ft_item_line.ebs_fcr_prod_ft_item_id = ebs_fcr_prod_ft_item.id
            ebs_fcr_ft_item_line.line_no     = line_no
            ebs_fcr_ft_item_line.trg_line_no = trg_line_no
            ebs_fcr_ft_item_line.trg_status  = trg_status
            ebs_fcr_ft_item_line.trg_text    = trg_text
            ebs_fcr_ft_item_line.src_line_no = src_line_no
            ebs_fcr_ft_item_line.src_status  = src_status
            ebs_fcr_ft_item_line.src_text    = src_text

            #print(ebs_fcr_prod_ft_item.id)
            #print(line_no)
            #print(trg_line_no)
            #print(trg_status)
            #print(trg_text)
            #print(src_line_no)
            #print(src_status)
            #print(src_text)

            ebs_fcr_ft_item_line.upsert()
            # Skipping appending line to list to avoid using memory unnecessarliy
            #ebs_fcr_prod_ft_item.list_ebs_fcr_ft_item_line.append(ebs_fcr_ft_item_line)
            ebs_fcr_ft_item_line = None
        
    
    
    
    def html_parser(self, html_filename):
        soup = None
        #print("html: " + html_filename)
        with open(html_filename) as fp:
            #soup = BeautifulSoup(fp, 'html.parser')
            soup = BeautifulSoup(fp, 'html5lib')
            fp.close()
        return soup
    
    
    def to_int(self, strint):
        try:
            return int(strint)
        except:
            return 0
        
   
    def get_ebs_version_by_short_label(self, ebs_version_short_label):
        for ebs_version in self.list_ebs_version:
            if ( ebs_version.ebs_version_short_label == ebs_version_short_label ):
                return ebs_version
        return None
    

    def get_ebs_version_by_label(self, ebs_version_label):
        for ebs_version in self.list_ebs_version:
            if ( ebs_version.ebs_version_label == ebs_version_label ):
                return ebs_version
        return None
    
    def get_ebs_family_by_ebs_product_code(self, ebs_product_code):
        for ebs_family in self.ebs_version.list_ebs_family:
            for ebs_product in ebs_family.list_ebs_product:
                if ( ebs_product.ebs_product_code == ebs_product_code ):
                    return ebs_family
        return None
    
    
    def upsert_filetype_item(self, 
                             ebs_fcr_prod_filetype, 
                             action_type, 
                             item_filename,
                             item_version,
                             item_src_version,
                             item_comparison_html_path):
        ebs_fcr_prod_ft_item = dao_ebs_fcr_prod_ft_item()
        ebs_fcr_prod_ft_item.ebs_fcr_prod_filetype_id  = ebs_fcr_prod_filetype.id
        ebs_fcr_prod_ft_item.action_type               = action_type
        ebs_fcr_prod_ft_item.item_filename             = item_filename
        ebs_fcr_prod_ft_item.item_version              = item_version
        ebs_fcr_prod_ft_item.item_src_version          = item_src_version
        ebs_fcr_prod_ft_item.item_comparison_html_path = item_comparison_html_path
        ebs_fcr_prod_ft_item.upsert()
        ebs_fcr_prod_filetype.list_ebs_fcr_prod_ft_item.append(ebs_fcr_prod_ft_item)
        #print("    --> action_type: " + action_type + " item_filename: " + item_filename)
            

