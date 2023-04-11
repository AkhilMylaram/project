# -*- coding: utf-8 -*-
"""
Created on Tue Mar 10 15:45:15 2020

@author: Walter-Montalvo
"""


from dao import dao
   
class dao_ebs_fcr(dao):
        
    def __init__(self):
        super().__init__("ebs_fcr", 
                         "ebs_fcr_seq", 
                         ("ebs_version", ), 
                         ("ebs_version_id", "ebs_version", "ebs_fcr_dir_name", "parser_version", "parse_startdate", "parse_enddate"))
        self.id = None
        self.ebs_version_id     = None
        self.ebs_version        = None
        self.ebs_fcr_dir_name   = None
        self.date_generated     = None
        self.parser_version     = None
        self.parse_startdate    = None
        self.parse_enddate      = None
    
        self.list_ebs_fcr_src = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_fcr_src(dao):
        
    def __init__(self):
        super().__init__("ebs_fcr_src", 
                         "ebs_fcr_src_seq", 
                         ("ebs_fcr_id", "src_ebs_version_id"), 
                         ("ebs_fcr_id", "src_ebs_version_id", "src_ebs_version"))
        self.id = None
        self.ebs_fcr_id = None
        self.src_ebs_version_id = None
        self.src_ebs_version = None
    
        self.list_ebs_product     = []
        self.list_ebs_fcr_product = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_fcr_product(dao):
        
    def __init__(self):
        super().__init__("ebs_fcr_product", 
                         "ebs_fcr_product_seq", 
                         ("ebs_fcr_src_id", "ebs_product_id"), 
                         ("ebs_fcr_src_id", "ebs_product_id", "ebs_product_code", "num_added", "num_removed", "num_stubbed", "num_changed", "num_unchanged"))
        self.id = None
        self.ebs_fcr_src_id = None
        self.ebs_product_id = None
        self.ebs_product_code = None
        self.num_added     = None
        self.num_removed   = None
        self.num_stubbed   = None
        self.num_changed   = None
        self.num_unchanged = None
    
        self.list_ebs_fcr_prod_filetype = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_fcr_prod_filetype(dao):
        
    def __init__(self):
        super().__init__("ebs_fcr_prod_filetype", 
                         "ebs_fcr_prod_filetype_seq", 
                         ("ebs_fcr_product_id", "filetype_label"), 
                         ("ebs_fcr_product_id", "filetype_label", "filetype_description", "num_added", "num_removed", "num_stubbed", "num_changed", "num_unchanged"))
        self.id = None
        self.ebs_fcr_product_id = None
        self.filetype_label = None
        self.filetype_description = None
        self.num_added     = None
        self.num_removed   = None
        self.num_stubbed   = None
        self.num_changed   = None
        self.num_unchanged = None
    
        self.list_ebs_fcr_prod_ft_item = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_fcr_prod_ft_item(dao):
        
    def __init__(self):
        super().__init__("ebs_fcr_prod_ft_item", 
                         "ebs_fcr_prod_ft_item_seq", 
                         ("ebs_fcr_prod_filetype_id", "action_type", "item_filename"), 
                         ("ebs_fcr_prod_filetype_id", "action_type", "item_filename", "item_version", "item_src_version", "item_comparison_html_path"))
        self.id = None
        self.ebs_sdcr_prod_datatype_id = None
        self.action_type = None
        self.item_filename = None
        self.item_version = None
        self.item_src_version = None
        self.item_comparison_html_path = None

        self.list_ebs_fcr_ft_item_line = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_fcr_ft_item_line(dao):
        
    def __init__(self):
        super().__init__("ebs_fcr_ft_item_line", 
                         "ebs_fcr_ft_item_line_seq", 
                         ("ebs_fcr_prod_ft_item_id", "line_no"), 
                         ("ebs_fcr_prod_ft_item_id", "line_no", "trg_line_no", "trg_status", "trg_text", "src_line_no", "src_status", "src_text"))
        self.id = None
        self.ebs_fcr_prod_ft_item_id = None
        self.line_no                 = None
        self.trg_line_no             = None
        self.trg_status              = None
        self.trg_text                = None
        self.src_line_no             = None
        self.src_status              = None
        self.src_text                = None
        
    def upsert(self):
        super().upsert()


