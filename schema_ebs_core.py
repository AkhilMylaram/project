# -*- coding: utf-8 -*-
"""
Created on Mon Feb 24 14:33:32 2020

@author: Walter-Montalvo
"""

from dao import dao
   
class dao_ebs_version(dao):
        
    def __init__(self):
        super().__init__("ebs_version", 
                         "ebs_version_seq", 
                         ("ebs_version_label", ), 
                         ("ebs_version_label", "ebs_version_short_label", "ebs_version_fcr_label", "ebs_version_description"))
        self.id                      = None
        self.ebs_version_label       = None
        self.ebs_version_short_label = None
        self.ebs_version_fcr_label   = None
        self.ebs_version_description = None
    
        self.list_ebs_family      = []
        self.all_ebs_product      = None
        self.list_ebs_product     = []
        self.ebs_sdcr      = None
        self.list_ebs_sdcr_src    = []
    
    def upsert(self):
        super().upsert()
    
    def add_all_product(self):
        ebs_product = dao_ebs_product()
        ebs_product.ebs_version_id = self.id
        ebs_product.ebs_product_code = "all"
        ebs_product.ebs_product_description = "Non-striped product"
        ebs_product.upsert()


class dao_ebs_family(dao):
        
    def __init__(self):
        super().__init__("ebs_family", 
                         "ebs_family_seq", 
                         ("ebs_version_id", "ebs_family_code"), 
                         ("ebs_version_id", "ebs_family_code", "ebs_family_description"))
        self.id = None
        self.ebs_version_id = None
        self.ebs_family_code = None
        self.ebs_family_description = None
    
        self.list_ebs_product = []
    
    def upsert(self):
        super().upsert()


class dao_ebs_product(dao):
        
    def __init__(self):
        super().__init__("ebs_product", 
                         "ebs_product_seq", 
                         ("ebs_version_id", "ebs_product_code"), 
                         ("ebs_version_id", "ebs_product_code", "ebs_product_description", "ebs_family_id", "striped"))
        self.id = None
        self.ebs_version_id          = None
        self.ebs_product_code        = None
        self.ebs_product_description = None
        self.ebs_family_id           = None
        self.striped                 = None
    
        self.list_ebs_sdcr_product = []
    
    def upsert(self):
        super().upsert()

