# -*- coding: utf-8 -*-
"""
Created on Tue Mar 10 13:40:03 2020

@author: Walter-Montalvo
"""

from bs4 import BeautifulSoup
from schema_ebs_core import *
from schema_ebs_dmcr import *

from pathlib import Path
import re
import datetime

"""

HTML Hierarchy

<REPORT_DIR_NAME>/summary_NZD.html


"""

class ebs_dmcr_scraper:
    
    object_type_from_label_dict = {
        'Regular_Tables': 'TABLE',
        'Partitioned_Tables': 'TABLE',
        'Queue_Tables': 'TABLE',
        'Index_Orgnized_Tables': 'TABLE',
        'Global_Temporary_Tables': 'TABLE',
        'New_Indexes_on_Existing_Tables_&_Columns': 'INDEX',
        'Indexes': 'INDEX',
        'New_Indexes_on_new_Tables_&_Columns': 'INDEX',
        'other_Index_Changes': 'INDEX',
        'Views': 'VIEW',
        'Sequences': 'SEQUENCE',
        'Materialized_Views': 'MATERIALIZED_VIEW',
        'Materialized_View_Logs': 'MATERIALIZED_VIEW_LOGS',
        'Advanced_Queues': 'ADVANCED_QUEUE',
        'Triggers': 'TRIGGER',
        'Packages': 'PACKAGE',
        'Types': 'TYPE',
        'Security_Object': 'SECURITY_OBJECT'
        }

    def __init__(self, ebs_dmcr_report, list_ebs_version):
        self.ebs_dmcr_dir_name = ebs_dmcr_report["ebs_dmcr_dir_name"]
        self.list_ebs_version = list_ebs_version
        self.trg_ebs_version = self.get_ebs_version_by_label(ebs_dmcr_report["trg_ebs_version"])
        self.src_ebs_version = self.get_ebs_version_by_label(ebs_dmcr_report["src_ebs_version"])
        self.parser_version = "1.2"

    
    def parse_report(self):
        # Extract list of products
        self.parse_summary()
        dao.connection.commit()
        for ebs_dmcr_product in self.ebs_dmcr.list_ebs_dmcr_product:
            print("  Product: (objects) " + ebs_dmcr_product.ebs_product_code)
            # TEST: onlu run FND
            #if ( ebs_dmcr_product.ebs_product_code != 'FND' ):
            #    continue
            # Extract list of db objects
            self.parse_diff(ebs_dmcr_product)
            dao.connection.commit()
        for ebs_dmcr_product in self.ebs_dmcr.list_ebs_dmcr_product:
            print("  Product: (text) " + ebs_dmcr_product.ebs_product_code)
            # Extract source code differences for views
            # TEST: onlu run FND
            #if ( ebs_dmcr_product.ebs_product_code != 'FND' ):
            #    continue
            self.parse_displayview(ebs_dmcr_product)
            dao.connection.commit()
        ebs_dmcr = self.ebs_dmcr
        ebs_dmcr.parse_enddate     = datetime.datetime.now()
        ebs_dmcr.upsert()
        dao.connection.commit()



    def parse_summary(self):
        html_file = ( self.ebs_dmcr_dir_name +
                     "/summary_NZD.html")
        soup = self.html_parser(html_file)
        
        self.ebs_dmcr = dao_ebs_dmcr()
        self.ebs_dmcr.trg_ebs_version_id = self.trg_ebs_version.id
        self.ebs_dmcr.trg_ebs_version    = self.trg_ebs_version.ebs_version_label
        self.ebs_dmcr.src_ebs_version_id = self.src_ebs_version.id
        self.ebs_dmcr.src_ebs_version    = self.src_ebs_version.ebs_version_label
        self.ebs_dmcr.ebs_dmcr_dir_name  = self.ebs_dmcr_dir_name
        self.ebs_dmcr.parser_version    = self.parser_version
        self.ebs_dmcr.parse_startdate   = datetime.datetime.now()
        self.ebs_dmcr.parse_enddate     = None

        self.ebs_dmcr.upsert()
        dao.connection.commit()
        
        self.ebs_dmcr.list_ebs_dmcr_product = []
        trs = soup.html.table.find_all("tr")
        for tr in trs:
            tds = tr.find_all("td")
            if ( tds == None ):
                continue
            atag = tds[0].a
            if ( atag == None ):
                continue
            product_href = atag.get("href")
            product_description = atag.get("title")
            product_code = atag.get_text()
            num_added = 0
            num_removed = 0
            num_changed = 0
            if ( len(tds) == 4 ):
                num_added   = tds[1].get_text()
                num_removed = tds[2].get_text()
                num_changed = tds[3].get_text()
            ebs_product = dao_ebs_product()
            ebs_product.ebs_version_id = self.trg_ebs_version.id
            ebs_product.ebs_product_code = product_code
            ebs_product.get_record_by_nk()
            ebs_product.ebs_product_description = product_description
            ebs_product.striped = "STRIPED"
            ebs_product.upsert()
            
            ebs_dmcr_product = dao_ebs_dmcr_product()
            ebs_dmcr_product.ebs_dmcr_id      = self.ebs_dmcr.id
            ebs_dmcr_product.ebs_product_id   = ebs_product.id
            ebs_dmcr_product.ebs_product_code = product_code
            ebs_dmcr_product.num_added        = num_added
            ebs_dmcr_product.num_removed      = num_removed
            ebs_dmcr_product.num_changed      = num_changed
            ebs_dmcr_product.upsert()
            self.ebs_dmcr.list_ebs_dmcr_product.append(ebs_dmcr_product)


    def parse_diff(self, ebs_dmcr_product):
        html_file = ( self.ebs_dmcr_dir_name +
                     "/" +
                     ebs_dmcr_product.ebs_product_code +
                     "_NZD_diff.html")
        soup = self.html_parser(html_file)
        print("DEBUG: parse_diff html file: " + html_file);
        
        ebs_dmcr_product.list_ebs_dmcr_object = []
        spans = soup.html.find_all("span")
        for span in spans:
            atag = span.find("a")
            if ( atag == None ):
                #print("DEBUG: <span> has not an <a>. Skipping");
                #print("DEBUG: " + span);
                continue
            object_type_label = atag.get("id")
            if ( object_type_label == None or 
                not ( object_type_label in ebs_dmcr_scraper.object_type_from_label_dict )):
                print("SKIPPING a.id:")
                print(object_type_label)
                sys.exit()
                continue
            object_type = ebs_dmcr_scraper.object_type_from_label_dict[object_type_label]
            table = span.nextSibling
            if (table.name != "table"): # The next node is not necessarily a table
                object_type_label = None
                object_type       = None
                #print("DEBUG: <span.nextSibling> is not a <table>. Skipping");
                #print("DEBUG: " + table);
                continue
            trs = table.find_all("tr")
            print("DEBUG: <span> has <table> with object_type: " + object_type_label + ". number of <tr> elements: " + str(len(trs)) + ". OK");
            #print("DEBUG: <table>")
            #print("DEBUG: " + table);
            #print("DEBUG: <trs>")
            #print("DEBUG: " + trs);
            for tr in trs:
                tds = tr.find_all("td")
                if ( len(tds) < 2 ):
                    #print("DEBUG: <tr> has less than 2 elements. Skipping");
                    #print("DEBUG: " + tr);
                    continue
                #print("DEBUG: <tr> OK");
                #print("DEBUG: " | tr);
                """<td>
                <font style="color: rgb(58, 90, 135); font-weight: bold;">Objects Added in 12.2.8</font>
                <br>
                <strong>col</strong>
                -NAME#1
                <br>
                <br>
                <font style="color: rgb(58, 90, 135); font-weight: bold;"> Attribute Changes  between 11iMBL and 12.2.8 </font>
                <br>
                <strong>col</strong>
                -NAME
                <font style="color: black; font-weight: bold;">:nullable:</font>
                N =&gt; 
                <font color="#FF0000">Y</font>
                <br>
                </td>"""

                object_name = tds[0].get_text()
                #change_object_attr = tds[1].get_text()
                change_object_attr = ""
                td_node = tds[1].contents[0]
                while ( td_node != None ):
                    if ( td_node.name != None ):
                        if ( td_node.name == "br" ):
                            change_object_attr += "\n"
                        else:
                            change_object_attr += td_node.get_text()
                    else:
                        change_object_attr += td_node
                    td_node = td_node.nextSibling
                change_type = 'None'
                if ( re.match("^Added in", change_object_attr) ):
                        change_type = 'Added'
                elif ( re.match("^Removed in", change_object_attr) ):
                        change_type = 'Removed'
                else:
                        change_type = 'Changed'
                if ( re.match("^New", object_type_label) ):
                        change_type = 'Added'
               
                #print("DEBUG: Inserting object_type: " + object_type + " object_name: " + object_name + " object_type_label: " + object_type_label + " change_type: " + change_type + " change_object_attr: " + change_object_attr);
                ebs_dmcr_object = dao_ebs_dmcr_object()
                ebs_dmcr_object.ebs_dmcr_product_id = ebs_dmcr_product.id
                ebs_dmcr_object.object_type         = object_type
                ebs_dmcr_object.object_name         = object_name
                ebs_dmcr_object.object_type_label   = object_type_label
                ebs_dmcr_object.change_type         = change_type
                ebs_dmcr_object.change_object_attr  = change_object_attr  
                ebs_dmcr_object.upsert()
                ebs_dmcr_product.list_ebs_dmcr_object.append(ebs_dmcr_object)
                dao.connection.commit()
                #print("DEBUG: commit OK");
                
            
    def parse_displayview(self, ebs_dmcr_product):
        html_filename = ( self.ebs_dmcr_dir_name +
                     "/" +
                     ebs_dmcr_product.ebs_product_code +
                     "_Views_NZD_displayview.html")
        if ( not Path(html_filename).is_file() ):
            return

        html_lines = []
        with open(html_filename, "r") as html_file:
            closed_td = False
            for line in html_file:
                if ( re.search("^ *<tr> *$", line) and closed_td ):
                    line = line.replace("<tr>", "</tr>")
                    html_lines.append(line)
                    continue
                line = line.replace("</div>", "</td>")
                html_lines.append(line)
                closed_td = False
                if ( re.search("</td> *$", line) ):
                    closed_td = True
        html_text = "\n".join(html_lines)
        
        print(html_filename)
        #print(html_text)
        soup = BeautifulSoup(html_text, 'html.parser')
        
        tables = soup.find_all("table")
        for table in tables:
            print("table")
            trs = table.find_all("tr")
            for tr in trs:
                tds = tr.find_all("td")
                if ( len(tds) < 3 ):
                    print("tds<3")
                    continue
                atag = tds[0].a
                if ( atag == None ):
                    print("atag==None")
                    continue
                view_name = atag.get("id")
                if ( view_name == None ):
                    print("view_name==None")
                    continue
                ebs_dmcr_object_id = None
                trg_text = tds[1].get_text()
                src_text = tds[2].get_text()
                found_ebs_dmcr_object = None
                for ebs_dmcr_object in ebs_dmcr_product.list_ebs_dmcr_object:
                    if ( ebs_dmcr_object.object_type == "VIEW" and 
                        ebs_dmcr_object.object_name == view_name ):
                        found_ebs_dmcr_object = ebs_dmcr_object
                        break
                if ( found_ebs_dmcr_object == None ):
                    print("found_ebs_dmcr_object == None")
                    continue
            
                ebs_dmcr_text = dao_ebs_dmcr_text()
                ebs_dmcr_text.ebs_dmcr_object_id = found_ebs_dmcr_object.id
                ebs_dmcr_text.trg_text           = trg_text
                ebs_dmcr_text.src_text           = src_text 
                ebs_dmcr_text.upsert()
                dao.connection.commit()
                # Skip appending text object to list to avoid consuming memory
                #found_ebs_dmcr_object.list_ebs_dmcr_text.append(ebs_dmcr_text)
                ebs_dmcr_text = None
    

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
        
   
    def get_ebs_version_by_label(self, ebs_version_label):
        for ebs_version in self.list_ebs_version:
            if ( ebs_version.ebs_version_label == ebs_version_label ):
                return ebs_version
        return None
    
