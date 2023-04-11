# -*- coding: utf-8 -*-
"""
Created on Tue Mar 10 15:45:15 2020

@author: Walter-Montalvo
"""


from dao import dao
   
class dao_ebs_dmcr(dao):
        
    def __init__(self):
        super().__init__("ebs_dmcr", 
                         "ebs_dmcr_seq", 
                         ("trg_ebs_version", "src_ebs_version"), 
                         ("trg_ebs_version_id", "trg_ebs_version", "src_ebs_version_id", "src_ebs_version", "ebs_dmcr_dir_name", "parser_version", "parse_startdate", "parse_enddate"))
        self.id = None
        self.trg_ebs_version_id = None
        self.trg_ebs_version    = None
        self.src_ebs_version_id = None
        self.src_ebs_version    = None
        self.ebs_dmcr_dir_name  = None
        self.parser_version     = None
        self.parse_startdate    = None
        self.parse_enddate      = None
    
        self.list_ebs_dmcr_product = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_dmcr_product(dao):
        
    def __init__(self):
        super().__init__("ebs_dmcr_product", 
                         "ebs_dmcr_product_seq", 
                         ("ebs_dmcr_id", "ebs_product_id"), 
                         ("ebs_dmcr_id", "ebs_product_id", "ebs_product_code", "num_added", "num_removed", "num_changed"))
        self.id = None
        self.ebs_dmcr_id      = None
        self.ebs_product_id   = None
        self.ebs_product_code = None
        self.num_added    = None
        self.num_removed  = None
        self.num_changed  = None
    
        self.list_ebs_dmcr_object = []
    
    def upsert(self):
        super().upsert()



class dao_ebs_dmcr_object(dao):
        
    def __init__(self):
        super().__init__("ebs_dmcr_object", 
                         "ebs_dmcr_object_seq", 
                         ("ebs_dmcr_product_id", "object_type", "object_name"), 
                         ("ebs_dmcr_product_id", "object_type_label", "object_type", "object_name", "change_type", "change_object_attr"))
        self.id = None
        self.ebs_dmcr_product_id = None
        self.object_type         = None
        self.object_name         = None
        self.object_type_label   = None
        self.change_type         = None
        self.change_object_attr  = None
    
        self.list_ebs_dmcr_text = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_dmcr_text(dao):
        
    def __init__(self):
        super().__init__("ebs_dmcr_text", 
                         "ebs_dmcr_text_seq", 
                         ("ebs_dmcr_object_id", ), 
                         ("ebs_dmcr_object_id", "trg_text", "src_text"))
        self.id = None
        self.ebs_dmcr_object_id = None
        self.trg_text           = None
        self.src_text           = None
    
    
    def upsert(self):
        super().upsert()




