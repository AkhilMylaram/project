# -*- coding: utf-8 -*-
"""
Created on Sun Feb 23 18:29:11 2020

@author: Walter-Montalvo
"""


from bs4 import BeautifulSoup
from schema_ebs_core import *
from schema_ebs_sdcr import *

import datetime

"""

HTML Hierarchy

<REPORT_EBS_VERSION>/Data/header.html
----------------
- ebs_version
List FAMILY
- family_code
- family_description


<REPORT_EBS_VERSION>/Data/<FAMILY_CODE>/index.html
--------------------------------------
- data_generated
X-axis
- List of <trg_ebs_version> vs <src_ebs_version>
-- src_ebs_version
Y-axis
- List of products
-- product_code
-- product_description
Cells
- num_added
- num_removed
- num_changed

<REPORT_EBS_VERSION>/Data/<FAMILY_CODE>/<PRODUCT_CODE>_diff_report.html
------------------------------------------------------
<a name="<trg_ebs_version>-<src_ebs_version>">
- Anchor for trg and src
- trg_ebs_version
- src_ebs_version
List of datatypes
- datatype_label
- datatype_description
- num_added
- num_removed
- num_changed

<REPORT_EBS_VERSION>/Data/<FAMILY_CODE>/<trg_ebs_version>-<src_ebs_version>/<DATATYPE_LABEL>.<PRODUCT_CODE>.html
------------------------------------------------------
<a name=diffitems>Summary of items Changed in 12.2.9</a></h2><table class=dataTable
- List of changed items
-- object_type
-- product_code
-- object_name
<a name=newitems>Summary of items Removed in 12.2.9</a>
- List of removed items
-- object_type
-- product_code
-- object_name
<a name=olditems>Summary of items Added in 12.2.9</a>
- List of added items
-- object_type
-- product_code
-- object_name


"""

class ebs_sdcr_scraper:
    
    def __init__(self, ebs_sdcr_report, list_ebs_version):
        self.ebs_sdcr_dir_name = ebs_sdcr_report["ebs_sdcr_dir_name"]
        self.list_ebs_version = list_ebs_version
        self.ebs_version = self.get_ebs_version_by_label(ebs_sdcr_report["ebs_version_label"])
        self.parser_version = "1.1"
    
    def parse_report(self):
        # Extract list of family codes, 
        # populate:
        # ebs_version.ebs_sdcr
        # ebs_version.list_ebs_family,
        self.parse_header() 
        dao.connection.commit()
        for ebs_family in self.ebs_version.list_ebs_family:
            print("  Family: " + ebs_family.ebs_family_code)
            # Extract report metadata, list of src_ebs_versions, list of products
            # populate: 
            # ebs_sdcr.date_generated,
            # ebs_sdcr.list_ebs_sdcr_src,
            # ebs_family.list_ebs_product, 
            # ebs_sdcr_src.list_ebs_sdcr_product
            self.parse_index(ebs_family) 
            dao.connection.commit()
            for ebs_sdcr_src in self.ebs_version.ebs_sdcr.list_ebs_sdcr_src:
                print("    SRC_EBS_VERSION: " + ebs_sdcr_src.src_ebs_version)
                for ebs_sdcr_product in ebs_sdcr_src.list_ebs_sdcr_product:
                    if ( ebs_sdcr_product.ebs_product_code == "all" ):
                        all_ebs_sdcr_product = ebs_sdcr_product
                for ebs_sdcr_product in ebs_sdcr_src.list_ebs_sdcr_product:
                    if ( ebs_sdcr_product.ebs_product_code == "all" ):
                        continue
                    print("      Product_code: " + ebs_sdcr_product.ebs_product_code)
                    # Extract datatype metadata and stats
                    # Populate:
                    # ebs_sdcr_product.list_ebs_sdcr_prod_datatype
                    self.parse_diff_report(ebs_family, ebs_sdcr_src, ebs_sdcr_product, all_ebs_sdcr_product)
                    dao.connection.commit()
                # Now parse the datatype items, but this time include the "all" product
                for ebs_sdcr_product in ebs_sdcr_src.list_ebs_sdcr_product:
                    print("      Product_code: " + ebs_sdcr_product.ebs_product_code)
                    for ebs_sdcr_prod_datatype in ebs_sdcr_product.list_ebs_sdcr_prod_datatype:
                        print("          Datatype: " + ebs_sdcr_prod_datatype.datatype_label)
                        # Extract list of items for datatype
                        # populate
                        # ebs_sdcr_prod_datatype.list_ebs_sdcr_prod_dt_item
                        self.parse_datatype_item(ebs_family, ebs_sdcr_src, ebs_sdcr_product, ebs_sdcr_prod_datatype)
                        dao.connection.commit()
                        ebs_sdcr_prod_datatype = None
                    ebs_sdcr_product.list_ebs_sdcr_prod_datatype = []
                ebs_sdcr_src.list_ebs_sdcr_product = []
            self.ebs_version.ebs_sdcr.list_ebs_sdcr_src = []
        ebs_sdcr = self.ebs_version.ebs_sdcr
        ebs_sdcr.parse_enddate     = datetime.datetime.now()
        ebs_sdcr.upsert() 
        dao.connection.commit()
    
    def parse_header(self):
        ebs_sdcr = dao_ebs_sdcr()
        ebs_sdcr.ebs_version_id    = self.ebs_version.id
        ebs_sdcr.ebs_version       = self.ebs_version.ebs_version_label
        ebs_sdcr.ebs_sdcr_dir_name = self.ebs_sdcr_dir_name
        ebs_sdcr.parser_version    = self.parser_version
        ebs_sdcr.parse_startdate   = datetime.datetime.now()
        ebs_sdcr.parse_enddate     = None
        self.ebs_version.ebs_sdcr = ebs_sdcr
        ebs_sdcr.upsert() 
        
        soup = self.html_parser(self.ebs_sdcr_dir_name + 
                                "/Data/header.html")
        family_select = soup.find(id="rup")
        family_options = family_select.find_all("option")
        for family_option in family_options:
            ebs_family = dao_ebs_family()
            ebs_family.ebs_version_id = self.ebs_version.id
            ebs_family.ebs_family_code = family_option.get('value')
            ebs_family.ebs_family_description = family_option.get_text().replace(u'\xa0', u' ')
            self.ebs_version.list_ebs_family.append(ebs_family)
            ebs_family.upsert()
        
    
    def parse_index(self, ebs_family):
        soup = self.html_parser(self.ebs_sdcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code.upper() + 
                                "/index.html")
        body_html = soup.find("body")
        date_generated = body_html.get_text().split('Generated on:')[1].split()[0]
        self.ebs_version.ebs_sdcr.date_generated = date_generated
        self.ebs_version.ebs_sdcr.upsert()
        
        # Extract list of src_ebs_versions
        # Populate ebs_sdcr.list_ebs_sdcr_src
        list_ebs_sdcr_src = []
        ebs_column_headers = soup.find("table").find('tr').find_all('th')
        for ebs_column_header in ebs_column_headers:
            header_text = ebs_column_header.get_text()
            if ( ' Vs ' in header_text ):
                #print(header_text)
                src_ebs_version = header_text.split(' Vs ')[1]
                #print(src_ebs_version)
                ebs_sdcr_src = dao_ebs_sdcr_src()
                ebs_sdcr_src.ebs_sdcr_id = self.ebs_version.ebs_sdcr.id
                ebs_sdcr_src.src_ebs_version_id = self.get_ebs_version_id_by_label(src_ebs_version)
                ebs_sdcr_src.src_ebs_version    = src_ebs_version
                ebs_sdcr_src.list_ebs_sdcr_product = []
                ebs_sdcr_src.upsert()
                list_ebs_sdcr_src.append(ebs_sdcr_src)
        self.ebs_version.ebs_sdcr.list_ebs_sdcr_src = list_ebs_sdcr_src
        
        # Extract list of products, and stats by src_ebs_version
        # Populate:
        # ebs_family.list_ebs_product, 
        # ebs_sdcr_src.list_ebs_sdcr_product
        list_ebs_product = []
        for tr in soup.find("table").find_all("tr"):
            td = tr.find("td")
            if ( td == None ):
                continue
            atag = td.find("a")
            if ( atag != None ):
                ebs_product_code = atag.get_text()
                ebs_product_description = atag.get("title")
            else:
                td_text = td.get_text()
                if ( "ALL" in td_text ):
                    ebs_product_code = "all"
                    ebs_product_description = "Non-striped product"
                else:
                    continue
            ebs_product = dao_ebs_product()
            ebs_product.ebs_version_id = self.ebs_version.id
            ebs_product.ebs_product_code = ebs_product_code
            ebs_product.ebs_product_description = ebs_product_description
            if ( ebs_product_code != "all" ):
                ebs_product.ebs_family_id = ebs_family.id
                ebs_product.striped = "STRIPED"
            else:
                ebs_product.ebs_family_id = None
                ebs_product.striped = None
            ebs_product.upsert()
            list_ebs_product.append(ebs_product)
            list_tds = tr.find_all('td')
            idx = 1
            for ebs_sdcr_src in list_ebs_sdcr_src:
                ebs_sdcr_product = dao_ebs_sdcr_product()
                ebs_sdcr_product.ebs_sdcr_src_id  = ebs_sdcr_src.id
                ebs_sdcr_product.ebs_product_id   = ebs_product.id
                ebs_sdcr_product.ebs_product_code = ebs_product.ebs_product_code
                ebs_sdcr_product.num_added        = self.to_int(list_tds[idx+1].get_text())
                ebs_sdcr_product.num_removed      = self.to_int(list_tds[idx+2].get_text())
                ebs_sdcr_product.num_changed      = self.to_int(list_tds[idx+3].get_text())
                ebs_sdcr_product.upsert()
                ebs_sdcr_src.list_ebs_sdcr_product.append(ebs_sdcr_product)
                #print("col cell: " +ebs_family.ebs_family_code + "," + ebs_product_code + ":" + list_tds[idx+1].get_text() + ":" + list_tds[idx+2].get_text() + ":" + list_tds[idx+3].get_text() + ":")
                idx += 4
        ebs_family.list_ebs_product = list_ebs_product
                
                
        pass
    
    def parse_diff_report(self, ebs_family, ebs_sdcr_src, ebs_sdcr_product, all_ebs_sdcr_product):
        # Extract datatype metadata and stats
        # Populate:
        # ebs_sdcr_product.list_ebs_sdcr_prod_datatype
        soup = self.html_parser(self.ebs_sdcr_dir_name + 
                                "/Data/" + 
                                ebs_family.ebs_family_code.upper() + 
                                "/" + 
                                ebs_sdcr_product.ebs_product_code + 
                                "_diff_report.html")
        list_tr = soup.find_all('tr')
        ebs_sdcr_product.list_ebs_sdcr_prod_datatype = []
        all_ebs_sdcr_product.list_ebs_sdcr_prod_datatype = []
        for tr in list_tr:
            list_td = tr.find_all('td')
            if ( list_td == [] ):
                continue
            atag = list_td[0].find('a')
            if ( atag == None ):
                continue
            ahref = atag.get('href')
            atexts = ahref.split("'")
            ebs_product_code = atexts[1]
            src_ebs_version = atexts[3].split('-')[1]
            datatype_label = atexts[5]
            if ( src_ebs_version  != ebs_sdcr_src.src_ebs_version or 
                 ebs_product_code != ebs_sdcr_product.ebs_product_code ):
                continue
            ebs_sdcr_prod_datatype = dao_ebs_sdcr_prod_datatype()
            if ( list_td[1].get('colspan') == None):
                ebs_sdcr_prod_datatype.ebs_sdcr_product_id  = ebs_sdcr_product.id
                ebs_sdcr_prod_datatype.datatype_label       = datatype_label
                ebs_sdcr_prod_datatype.datatype_description = datatype_label
                ebs_sdcr_prod_datatype.num_added            = self.to_int(list_td[1].get_text())
                ebs_sdcr_prod_datatype.num_removed          = self.to_int(list_td[2].get_text())
                ebs_sdcr_prod_datatype.num_changed          = self.to_int(list_td[3].get_text())
                ebs_sdcr_product.list_ebs_sdcr_prod_datatype.append(ebs_sdcr_prod_datatype)
                #print("            [dt]: " + ebs_product_code + ":" + src_ebs_version + ":" + datatype_label + ":" + str(ebs_sdcr_prod_datatype.num_added)  + ":" + str(ebs_sdcr_prod_datatype.num_removed)  + ":" + str(ebs_sdcr_prod_datatype.num_changed) )
            else:
                ebs_sdcr_prod_datatype.ebs_sdcr_product_id  = all_ebs_sdcr_product.id
                ebs_sdcr_prod_datatype.datatype_label       = datatype_label
                ebs_sdcr_prod_datatype.datatype_description = datatype_label
                ebs_sdcr_prod_datatype.num_added            = 0
                ebs_sdcr_prod_datatype.num_removed          = 0
                ebs_sdcr_prod_datatype.num_changed          = 0
                all_ebs_sdcr_product.list_ebs_sdcr_prod_datatype.append(ebs_sdcr_prod_datatype)
                #print("            [dt-nostripe]: " + ebs_product_code + ":" + src_ebs_version + ":" + datatype_label + ":" + str(ebs_sdcr_prod_datatype.num_added)  + ":" + str(ebs_sdcr_prod_datatype.num_removed)  + ":" + str(ebs_sdcr_prod_datatype.num_changed) )
            ebs_sdcr_prod_datatype.upsert()
            
    
    def parse_datatype_item(self, ebs_family, ebs_sdcr_src, ebs_sdcr_product, ebs_sdcr_prod_datatype):
        # Extract list of items for datatype
        # populate
        # ebs_sdcr_prod_datatype.list_ebs_sdcr_prod_dt_item
        ebs_sdcr_prod_datatype.list_ebs_sdcr_prod_dt_item = []
        ebs_sdcr_prod_datatype.dict_bookmark_2_item       = {}
        if ( ebs_sdcr_product.ebs_product_code != "all" ):
            html_file = (self.ebs_sdcr_dir_name + 
                         "/Data/" + 
                         ebs_family.ebs_family_code.upper() +
                         "/" + 
                         self.ebs_version.ebs_version_label + 
                         "-" + 
                         ebs_sdcr_src.src_ebs_version + 
                         "/" + 
                         ebs_sdcr_prod_datatype.datatype_label + 
                         "." + 
                         ebs_sdcr_product.ebs_product_code + 
                         ".html")
        else:
            html_file = (self.ebs_sdcr_dir_name + 
                         "/Data/" + 
                         ebs_family.ebs_family_code.upper() + 
                         "/" + 
                         self.ebs_version.ebs_version_label + 
                         "-" + 
                         ebs_sdcr_src.src_ebs_version + 
                         "/" + 
                         ebs_sdcr_prod_datatype.datatype_label + 
                         "_" + 
                         ebs_sdcr_product.ebs_product_code + 
                         ".html")
        soup = self.html_parser(html_file)
        #print(html_file)
        
        node = soup.html.contents[0]
        in_block = None
        cnt_small = -1
        while ( node != None ):
            if ( node.name == "h2" ):
                #print(node)
                in_block = None
                cnt_small = -1
                if ( node.a != None ):
                    if ( "Summary of items " in node.a.get_text() ):
                        if ( "Changed" in node.a.get_text() ):
                            in_block = "Changed"
                            cnt_small = -1
                            #print(in_block)
                            node = node.nextSibling
                            if ( node.name == "table" ):
                                #print(node)
                                for tr in node.find_all("tr"):
                                    if ( tr.find("td").find("a") != None ):
                                        tds = tr.find_all("td")
                                        bookmark = tds[0].a.get("href")
                                        item = tds[1].get_text()
                                        #print(item)
                                        self.upsert_datatype_item(ebs_sdcr_prod_datatype, in_block, item, bookmark)
                            in_block = None
                        elif ( "Removed" in node.a.get_text() ):
                            in_block = "Removed"
                            cnt_small = -1
                            #print(in_block)
                        elif ( "Added" in node.a.get_text() ):
                            in_block = "Added"
                            cnt_small = -1
                            #print(in_block)
            elif ( node.name == "small" and in_block != None ):
                cnt_small = 1
                bookmark = node.a.get("href")
                #print("SMALL")
                #print(node)
            elif ( cnt_small == 1 ):
                if ( node.name != None ):
                    item = node.get_text()
                else:
                    item = node
                #print(item)
                self.upsert_datatype_item(ebs_sdcr_prod_datatype, in_block, item, bookmark)
                cnt_small = -1
            node = node.nextSibling
            
            """
            
            <html>
            <head>
            ...
            </head>
            ....   (no <body>)
            
            <h2>Details of Differences in 12.2.9</h2>
<table class=dataTable cellspacing=0 cellpadding=0>
    <tr bgcolor=#A9BDFC>
        <td><b>12.2.9</b></td>
        <td> <b> 11IMBL </b> </td>
    </tr>
    <tr bgcolor=e8e8e8>
        <td valign=top><small><a name="bookmark18100"></a>BEGIN DESC_FLEX "FND"
                "$SRS$.AFFURGO2"<br>TABLE_APPLICATION_SHORT_NAME = "FND"<br>APPLICATI
                ...
    </table>
    
    
    
<br>
<h2>Details for items Removed in 12.2.9</h2>
<a name="bookmark18098"></a>BEGIN DESC_FLEX "FND" "$SRS$.AFDURG01"<br> 2006/03/02 00:00:00<br>
TABLE_APPLICATION_SHORT_NAME = "FND"<br> APP
....
"FND" "$SRS$.AFDURG02"<br> AUTO_ANNOTATION = "/**\n\<br> */"<br>END PROGRAM<p></p><br>

<br>
<h2>Details for items Added in 12.2.9</h2>
<a name="bookmark18097"></a>BEGIN DESC_FLEX "FND" "$SRS$.AFBFULDL"<br> 2006/06/25 00:00:00<br>
TABLE_APPLICATION_SHORT_NAME = "FND"<br> APPLICATION_TABLE_NA

            """
        
        node = soup.html.contents[0]
        in_block = None
        ebs_sdcr_prod_dt_item = None
        trg_text_lines = []
        src_text_lines = []
        while ( node != None ):
            if ( node.name == "h2" ):
                #print(node)
                in_block = None
                h2_text = node.get_text()
                if ( "Details of Differences " in h2_text ):
                    in_block = "Changed"
                    #print(in_block)
                    while True:
                        node = node.nextSibling
                        if ( node.name == "table" ):
                            break
                    #print(node)
                    for tr in node.find_all("tr"):
                        tds = tr.find_all("td")
                        atag = tds[0].find('a')
                        if ( atag == None ):
                            continue
                        bookmark = "#" + atag.get("name")
                        ebs_sdcr_prod_dt_item = ebs_sdcr_prod_datatype.dict_bookmark_2_item[bookmark]
                        if ( len(tds) < 2 ):
                            # NOTE: 2
                            # Skipping malformed <tr> blccks.  They are supposed to have two <td> elements
                            print("SKIPPING len(tds): " + str(len(tds)))
                            print("Changed Bookmark: " + bookmark)
                            continue
                        #print("ebs_sdcr_prod_dt_item:")
                        #print(ebs_sdcr_prod_dt_item)
                        trg_text_lines = self.extract_text_lines_from_td(tds[0])
                        src_text_lines = self.extract_text_lines_from_td(tds[1])
                        self.upsert_datatype_item_line(ebs_sdcr_prod_dt_item, in_block, trg_text_lines, src_text_lines)
                        ebs_sdcr_prod_dt_item = None
                        trg_text_lines = []
                        src_text_lines = []
                    in_block = None
                elif ( "Details for items Removed " in h2_text ):
                    if ( ebs_sdcr_prod_dt_item != None ):
                        self.upsert_datatype_item_line(ebs_sdcr_prod_dt_item, in_block, trg_text_lines, src_text_lines)
                    ebs_sdcr_prod_dt_item = None
                    trg_text_lines = []
                    src_text_lines = []
                    in_block = "Removed"
                    #print(in_block)
                elif ( "Details for items Added " in h2_text ):
                    if ( ebs_sdcr_prod_dt_item != None ):
                        self.upsert_datatype_item_line(ebs_sdcr_prod_dt_item, in_block, trg_text_lines, src_text_lines)
                    ebs_sdcr_prod_dt_item = None
                    trg_text_lines = []
                    src_text_lines = []
                    in_block = "Added"
                    #print(in_block)
            elif ( node.name == "a" ):
                if ( ebs_sdcr_prod_dt_item != None ):
                    self.upsert_datatype_item_line(ebs_sdcr_prod_dt_item, in_block, trg_text_lines, src_text_lines)
                ebs_sdcr_prod_dt_item = None
                trg_text_lines = []
                src_text_lines = []
                if ( node.get("name") == None ):
                    # NOTE: 3
                    # Skipping malformed <a> tag.  They are supposed to have a "name" attribute
                    print("BAD A TAG: in_block: " + in_block)
                    print(node)
                else:
                    # Extract bookmark and datatype item record
                    bookmark = "#" + node.get("name")
                    #print(in_block + " Bookmark: " + bookmark)
                    if ( bookmark in ebs_sdcr_prod_datatype.dict_bookmark_2_item ):
                        ebs_sdcr_prod_dt_item = ebs_sdcr_prod_datatype.dict_bookmark_2_item[bookmark]
                    else:
                        # NOTE:4 
                        # Some malformed bookmark items in the "Summary of items" section can 
                        # result in invalid bookmark in the above section.  
                        # Therefore, there will be bookmarks in the Details section which do not have a 
                        # refrencing link in the Summary section
                        # For those cases, we will skip those Detail records
                        ebs_sdcr_prod_dt_item = None
                    #print("ebs_sdcr_prod_dt_item:")
                    #print(ebs_sdcr_prod_dt_item)
            elif ( in_block != None and ebs_sdcr_prod_dt_item != None ): 
                # NOTE: 5
                # As mentioned in (NOTE:4) above, there might be cases where we are in a 
                # Detail section, but the records refer to a unrefernced bookmark.  
                # For those we skip (ebs_sdcr_prod_dt_item = None)
                if ( node.name == None ):
                    if ( in_block == "Removed" ):
                        src_text_lines.append(['N', node])
                    else:
                        trg_text_lines.append(['N', node])
            node = node.nextSibling
        if ( ebs_sdcr_prod_dt_item != None ):
            self.upsert_datatype_item_line(ebs_sdcr_prod_dt_item, in_block, trg_text_lines, src_text_lines)
        ebs_sdcr_prod_dt_item = None
        trg_text_lines = []
        src_text_lines = []
        in_block = None
        
    def extract_text_lines_from_td(self, td):
        #print("extract_text_lines_from_td-->START")
        #print(td)
        text_lines = []
        node = td
        if ( node.small != None ):
            node = node.small
        node = node.contents[0]
        while ( node != None ):
            #print(node)
            if ( node.name == None ):
                text_lines.append(['N', node])
                #print(" :" + node)
            elif ( node.name == "font" ):
                node_text = node.get_text()
                text_lines.append(['C', node_text])
                #print("C:" + node_text)
            node = node.nextSibling
        #print("extract_text_lines_from_td-->END")
        return text_lines
    
    def html_parser(self, html_filename):
        soup = None
        #print(html_filename)
        with open(html_filename) as fp:
            #soup = BeautifulSoup(fp, 'html.parser')
            soup = BeautifulSoup(fp, 'html5lib')
            fp.close()
        return soup
    
    def get_ebs_version_id_by_label(self, ebs_version_label):
        for ebs_version in self.list_ebs_version:
            if ( ebs_version.ebs_version_label == ebs_version_label ):
                return ebs_version.id
        return None
    
    def to_int(self, strint):
        try:
            return int(strint)
        except:
            return 0
        
    def upsert_datatype_item(self, ebs_sdcr_prod_datatype, action_type, item, bookmark):
        fields = item.split('"')
        if ( len(fields) == 3):
            # This is a non-striped object, so no item_product_code
            item_object_type  = fields[0].strip()
            item_product_code = " "
            item_object_name  = fields[1].strip()
        elif ( len(fields) > 3 ):
            item_object_type  = fields[0]
            item_product_code = fields[1].strip()
            item_object_name  = fields[3].strip()
        else:
            # NOTE: 1
            # There are some malformed Summary records,
            # ones that do not have any object type or object name
            # we skip thoise
            return
        
            
        ebs_sdcr_prod_dt_item = dao_ebs_sdcr_prod_dt_item()
        ebs_sdcr_prod_dt_item.ebs_sdcr_prod_datatype_id = ebs_sdcr_prod_datatype.id
        ebs_sdcr_prod_dt_item.action_type               = action_type
        ebs_sdcr_prod_dt_item.item_object_type          = item_object_type
        ebs_sdcr_prod_dt_item.item_product_code         = item_product_code
        ebs_sdcr_prod_dt_item.item_object_name          = item_object_name
        ebs_sdcr_prod_dt_item.bookmark                  = bookmark
        ebs_sdcr_prod_dt_item.upsert()
        ebs_sdcr_prod_datatype.list_ebs_sdcr_prod_dt_item.append(ebs_sdcr_prod_dt_item)
        ebs_sdcr_prod_datatype.dict_bookmark_2_item[bookmark] = ebs_sdcr_prod_dt_item


    def upsert_datatype_item_line(self, ebs_sdcr_prod_dt_item, in_block, trg_text_lines, src_text_lines):
        #print("udil:ebs_sdcr_prod_dt_item:")
        #print(ebs_sdcr_prod_dt_item)
        line_no = 0
        for (line_status, line_text) in trg_text_lines:
            line_no += 1
            ebs_sdcr_item_line = dao_ebs_sdcr_item_line()
            ebs_sdcr_item_line.ebs_sdcr_prod_dt_item_id = ebs_sdcr_prod_dt_item.id
            ebs_sdcr_item_line.trg_src   = "TRG"
            ebs_sdcr_item_line.line_no   = line_no
            ebs_sdcr_item_line.status    = line_status
            ebs_sdcr_item_line.line_text = line_text.encode('ascii', 'replace').decode('ascii')
            ebs_sdcr_item_line.upsert()
            ebs_sdcr_prod_dt_item.list_trg_ebs_sdcr_item_line.append(ebs_sdcr_item_line)
        line_no = 0
        for (line_status, line_text) in src_text_lines:
            line_no += 1
            ebs_sdcr_item_line = dao_ebs_sdcr_item_line()
            ebs_sdcr_item_line.ebs_sdcr_prod_dt_item_id = ebs_sdcr_prod_dt_item.id
            ebs_sdcr_item_line.trg_src   = "SRC"
            ebs_sdcr_item_line.line_no   = line_no
            ebs_sdcr_item_line.status    = line_status
            ebs_sdcr_item_line.line_text = line_text.encode('ascii', 'replace').decode('ascii')
            ebs_sdcr_item_line.upsert()
            ebs_sdcr_prod_dt_item.list_src_ebs_sdcr_item_line.append(ebs_sdcr_item_line)
        dao.connection.commit()            
            

    
    def get_ebs_version_by_label(self, ebs_version_label):
        for ebs_version in self.list_ebs_version:
            if ( ebs_version.ebs_version_label == ebs_version_label ):
                return ebs_version
        return None
    
    
    
