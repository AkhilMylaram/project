# -*- coding: utf-8 -*-
"""
Created on Wed Feb 26 14:05:40 2020

@author: Walter-Montalvo
"""


from bs4 import BeautifulSoup

html_file = 'C:/Dev/ebs-seeddata-comparison/12.1.3/EBS_ATG_Seed_Data_Comparison_Report/Data/ATG/12.1.3-11.5.10.2/Menus.JTF.html'
with open(html_file, 'r') as fp:
    soup = BeautifulSoup(fp, 'html.parser')
    fp.close()


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
                    print(in_block)
                    node = node.nextSibling
                    if ( node.name == "table" ):
                        #print(node)
                        for tr in node.find_all("tr"):
                            if ( tr.find("td").find("a") != None ):
                                item = tr.find_all("td")[1].get_text()
                                print(item)
                elif ( "Removed" in node.a.get_text() ):
                    in_block = "Removed"
                    cnt_small = -1
                    print(in_block)
                elif ( "Added" in node.a.get_text() ):
                    in_block = "Added"
                    cnt_small = -1
                    print(in_block)
    elif ( node.name == "small" and in_block != None ):
        cnt_small = 1
        #print("SMALL")
        #print(node)
    elif ( cnt_small == 1 ):
        if ( node.name != None ):
            item = node.get_text()
        else:
            item = node
        #print("TEXT")
        print(item)
        cnt_small = -1
    node = node.nextSibling
        