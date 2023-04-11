# -*- coding: utf-8 -*-
"""
Created on Mon Feb 24 14:33:32 2020

@author: Walter-Montalvo
"""

import cx_Oracle
from   rdbms_creds import rdbms_username, rdbms_password, rdbms_hostname, rdbms_port, rdbms_dbname

class dao:
    
    connection = None
    
    def __init__(self, table_name, sequence_name, natural_keys, column_names):
        self.table_name = table_name
        self.sequence_name = sequence_name
        self.natural_keys = natural_keys
        self.column_names = column_names
        self.select_id_sql           = None
        self.update_sql              = None
        self.insert_sql              = None
        self.select_record_by_nk_sql = None



    def upsert(self):
        """
        if self.id is None
            SELECT id
              INTO self.id
              FROM <TABLE> 
             WHERE <NATURAL KEY> = self.<NATURAL KEY>;
            if no rows
                SELECT <SEQUENCE>.nextval()
                  INTO self.id
                  FROM dual;
                INSERT INTO <TABLE> <COLUMNS>;
                RETURN
            endif
        endif
        UPDATE <TABLE>
           SET <COLUMNS>
         WHERE id = self.id;

        Returns
        -------
        None.

        """
        
        if ( self.id is None ):
            # Retrieve the id for the natural key
            (select_id_sql, key_values) = self.gen_select_id_by_nk_sql()
            #print("select_id_sql :" + select_id_sql)
            cursor = self.connection.cursor()
            cursor.execute(select_id_sql, key_values)
            (row) = cursor.fetchone()
            cursor.close()
            if ( row is None ):
                # An ID has not been created for the natural key.
                # Get a new ID
                select_seq_sql = "SELECT " + self.sequence_name + ".nextval FROM dual"
                #print("select_seq_sql :" + select_seq_sql)
                cursor = self.connection.cursor()
                cursor.execute(select_seq_sql)
                (self.id, ) = cursor.fetchone()
                cursor.close()
                # And create the new record
                (insert_sql, insert_values) = self.gen_insert_sql()
                #print("insert_sql :" + insert_sql)
                #print(insert_values)
                cursor = self.connection.cursor()
                cursor.execute(insert_sql, insert_values)
                cursor.close()
                return
            self.id = row[0]
            #print("id :" + str(self.id))
        # Since we have an ID for the record, update the record
        (update_sql, update_values) = self.gen_update_sql()
        #print("update_sql :" + update_sql)
        cursor = self.connection.cursor()
        cursor.execute(update_sql, update_values)
        cursor.close()
        
            
    def gen_select_id_by_nk_sql(self):
        if ( self.select_id_sql == None ):
            self.select_id_sql = "SELECT id FROM " + self.table_name + " WHERE"
            cnt=0
            for natural_key in self.natural_keys:
                #print("natural_kay: " + natural_key)
                if ( cnt != 0 ):
                    self.select_id_sql += " AND "
                self.select_id_sql += " " + natural_key + " = :" + natural_key
                cnt += 1
        key_values = []
        for natural_key in self.natural_keys:
            key_values.append(getattr(self, natural_key))
        return self.select_id_sql, key_values
    
    
    def gen_insert_sql(self):
        if ( self.insert_sql == None ):
            insert_columns_sql = "INSERT INTO " + self.table_name + " (id"
            insert_values_sql = "VALUES(:id"
            cnt=0
            for column_name in self.column_names:
                #print("column_name: " + column_name)
                insert_columns_sql += ", " + column_name
                insert_values_sql  += ", :" + column_name
                cnt += 1
            self.insert_sql = insert_columns_sql + ") " + insert_values_sql + ")"
        insert_values = [self.id]
        for column_name in self.column_names:
            insert_values.append(getattr(self, column_name))
        return self.insert_sql, insert_values
    
    
    def gen_update_sql(self):
        if ( self.update_sql == None ):
            self.update_sql = "UPDATE " + self.table_name + " SET "
            cnt=0
            for column_name in self.column_names:
                #print("column_name: " + column_name)
                if ( cnt != 0 ):
                    self.update_sql += ", "
                self.update_sql += column_name + " = :" + column_name
                cnt += 1
            self.update_sql += " WHERE id = :id"
        update_values = []
        for column_name in self.column_names:
            update_values.append(getattr(self, column_name))
        update_values.append(self.id)
        return self.update_sql, update_values
    
    
    def get_record_by_nk(self):
        if ( self.select_record_by_nk_sql == None ):
            null_nk_column = False
            for natural_key in self.natural_keys:
                if ( getattr(self, natural_key) == None ):
                    null_nk_column = True
            if ( null_nk_column ):
                return
            self.select_record_by_nk_sql = "SELECT id"
            for column_name in self.column_names:
                self.select_record_by_nk_sql += ", " + column_name
            self.select_record_by_nk_sql += " FROM " + self.table_name + " WHERE "
            cnt = 0
            for natural_key in self.natural_keys:
                if ( cnt != 0 ):
                    self.select_record_by_nk_sql += " AND "
                self.select_record_by_nk_sql += natural_key + " = :" + natural_key
                cnt += 1
        nk_values = []
        for natural_key in self.natural_keys:
            nk_values.append( getattr(self, natural_key) )
        cursor = self.connection.cursor()
        cursor.execute(self.select_record_by_nk_sql, nk_values)
        column_values = cursor.fetchone()
        cursor.close()
        if ( column_values == None ):
            return
        cnt = 0
        for column_value in column_values:
            if ( cnt == 0 ):
                self.id = column_value
            else:
                setattr(self, self.column_names[cnt - 1], column_value)
            cnt += 1
    
    
    def connect(self):
        dao.connection = cx_Oracle.connect(rdbms_username, rdbms_password, cx_Oracle.makedsn(rdbms_hostname, rdbms_port, rdbms_dbname))
        #dao.connection = cx_Oracle.connect(rdbms_username, rdbms_password, "orabuild-01.elghills.com:1521/DB12C")
    
    
    def disconnect(self):
        dao.connection.close()

    
