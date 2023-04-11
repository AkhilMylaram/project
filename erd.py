# -*- coding: utf-8 -*-
"""
Created on Sun Feb 23 19:47:33 2020

@author: Walter-Montalvo
"""


"""

ebs_version
===========
id
ebs_version_label
ebs_version_description


ebs_family
==========
id
ebs_version_id
ebs_family_code
ebs_family_description


ebs_product
===========
id
ebs_version_id
ebs_product_code
ebs_product_name
ebs_family_id

-- NOTE: For items that are not related to a product, 
-- we will create a placeholder product "CROSS_PRODUCT"
-- belonging to family "CROSS_PRODUCT"
-- This is to accomodate datatypes like Printer Styles and 
-- Requests Sets

ebs_sdcr
==============
id
ebs_version_id (o)
ebs_version
date_generated


ebs_sdcr_src
===============
id
ebs_sdcr_id
src_ebs_version_id (o)
src_ebs_version


ebs_sdcr_product
=================
id
ebs_sdcr_src_id
ebs_product_id (o)
ebs_product_code
num_added
num_removed
num_changed


ebs_sdcr_prod_datatype
======================
id
ebs_sdcr_product_id
datatype_label
datatype_description
num_added
num_removed
num_changed



ebs_sdcr_prod_dt_item
=====================
id
ebs_sdcr_prod_dt_id
action_type -- Add, Change, Remove
item_product_code
item_object_name


"""
