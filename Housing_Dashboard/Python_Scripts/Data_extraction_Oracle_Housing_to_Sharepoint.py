# Install below libraries before running the script

# pip install cx_Oracle
# pip install openpyxl

# Import all the required Libraries
import cx_Oracle
from openpyxl import Workbook
from datetime import datetime
import configparser

# Load the configuration file
config = configparser.ConfigParser()
config.read('H:/Housing_project/Code/config.ini')

#print(config['oracle'])
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
with open('H:/Housing_project/Code/Final_ATS_Consolidated.sql', 'r') as file:
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
wb.save("C:/Users/VREDDY/OneDrive - Government of BC/Documents - Data Governance and Analytics - BC Housing and Connectivity Initiative/BC Housing and Connectivity Initiative/ATS_Dataset.xlsx")

# close the cursor and database connection
cursor.close()
connection.close()
