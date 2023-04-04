# -*- coding: utf-8 -*-
"""
Spyder Editor


This is a temporary script file.
"""
import cx_Oracle
import pandas as pd
from io import BytesIO
from msal import ConfidentialClientApplication
from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.sharepoint.client_context import ClientContext
from office365.sharepoint.files.file import File
from office365.graph_client import GraphClient
import configparser

config = configparser.ConfigParser()
config.read('H:/Connectivity_project/Code/config.ini')

print(config['oracle'])
username = config['oracle']['username']
password = config['oracle']['password']
host = config['oracle']['host']
port = config['oracle']['port']
database = config['oracle']['database']


# Set up Oracle database connection
dsn = cx_Oracle.makedsn(host=host, port=port, service_name=database)
connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)

print('Oracle Connection Successfull')

# create a cursor object to execute SQL queries
cursor = connection.cursor()

# read the SQL query from a file
with open('H:/Connectivity_project/Code/Final_ATS_Consolidated_Connectivity.sql', 'r') as file:
    query = file.read()

# execute SQL query to retrieve data from the database
cursor.execute(query)

# create an Excel workbook and select the active worksheet
wb = Workbook()
ws = wb.active
ws.title ='Applications'


# get the column names from the result set metadata and write them to the first row of the worksheet
column_names = [column[0] for column in cursor.description]
ws.append(column_names)

# iterate over the cursor to retrieve the data and write it to the worksheet
for row in cursor:
    ws.append(row)

# save the Excel workbook
wb.save("C:/Users/VREDDY/OneDrive - Government of BC/Documents - Data Governance and Analytics - BC Housing and Connectivity Initiative/BC Housing and Connectivity Initiative/ATS_Connectivity_Dataset.xlsx")

# close the cursor and database connection
cursor.close()
connection.close()


