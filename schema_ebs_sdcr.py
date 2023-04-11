# -*- coding: utf-8 -*-
"""
Created on Mon Feb 24 14:33:32 2020

@author: Walter-Montalvo
"""

from dao import dao
   
class dao_ebs_sdcr(dao):
        
    def __init__(self):
        super().__init__("ebs_sdcr", 
                         "ebs_sdcr_seq", 
                         ("ebs_version", ), 
                         ("ebs_version_id", "ebs_version", "ebs_sdcr_dir_name", "date_generated", "parser_version", "parse_startdate", "parse_enddate"))
        self.id = None
        self.ebs_version_id     = None
        self.ebs_version        = None
        self.ebs_sdcr_dir_name  = None
        self.date_generated     = None
        self.parser_version     = None
        self.parse_startdate    = None
        self.parse_enddate      = None

    
        self.list_ebs_sdcr_src = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_sdcr_src(dao):
        
    def __init__(self):
        super().__init__("ebs_sdcr_src", 
                         "ebs_sdcr_src_seq", 
                         ("ebs_sdcr_id", "src_ebs_version_id"), 
                         ("ebs_sdcr_id", "src_ebs_version_id", "src_ebs_version"))
        self.id = None
        self.ebs_sdcr_id = None
        self.src_ebs_version_id = None
        self.src_ebs_version = None
    
        self.list_ebs_sdcr_product = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_sdcr_product(dao):
        
    def __init__(self):
        super().__init__("ebs_sdcr_product", 
                         "ebs_sdcr_product_seq", 
                         ("ebs_sdcr_src_id", "ebs_product_id"), 
                         ("ebs_sdcr_src_id", "ebs_product_id", "ebs_product_code", "num_added", "num_removed", "num_changed"))
        self.id = None
        self.ebs_sdcr_src_id = None
        self.ebs_product_id = None
        self.ebs_product_code = None
        self.num_added = None
        self.num_removed = None
        self.num_changed = None
    
        self.list_ebs_sdcr_prod_datatype = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_sdcr_prod_datatype(dao):
        
    def __init__(self):
        super().__init__("ebs_sdcr_prod_datatype", 
                         "ebs_sdcr_prod_datatype_seq", 
                         ("ebs_sdcr_product_id", "datatype_label"), 
                         ("ebs_sdcr_product_id", "datatype_label", "datatype_description", "num_added", "num_removed", "num_changed"))
        self.id = None
        self.ebs_sdcr_product_id = None
        self.datatype_label = None
        self.datatype_description = None
        self.num_added = None
        self.num_removed = None
        self.num_changed = None
    
        self.list_ebs_sdcr_prod_dt_item = []
        self.dict_bookmark_2_item       = {}
    
    def upsert(self):
        super().upsert()


class dao_ebs_sdcr_prod_dt_item(dao):
        
    def __init__(self):
        super().__init__("ebs_sdcr_prod_dt_item", 
                         "ebs_sdcr_prod_dt_item_seq", 
                         ("ebs_sdcr_prod_datatype_id", "action_type", "item_object_type", "item_product_code", "item_object_name"), 
                         ("ebs_sdcr_prod_datatype_id", "action_type", "item_object_type", "item_product_code", "item_object_name", "bookmark"))
        self.id = None
        self.ebs_sdcr_prod_datatype_id = None
        self.action_type       = None
        self.item_object_type  = None
        self.item_product_code = None
        self.item_object_name  = None
        self.bookmark          = None
        
        self.list_trg_ebs_sdcr_item_line = []
        self.list_src_ebs_sdcr_item_line = []
    
    
    def upsert(self):
        super().upsert()


class dao_ebs_sdcr_item_line(dao):
        
    def __init__(self):
        super().__init__("ebs_sdcr_item_line", 
                         "ebs_sdcr_item_line_seq", 
                         ("ebs_sdcr_prod_dt_item_id", "trg_src", "line_no"), 
                         ("ebs_sdcr_prod_dt_item_id", "trg_src", "line_no", "status", "line_text"))
        self.id = None
        self.ebs_sdcr_prod_dt_item_id = None
        self.trg_src                  = None
        self.line_no                  = None
        self.status                   = None
        self.line_text                = None
    
    
    def upsert(self):
        super().upsert()


