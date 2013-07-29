import pyodbc
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-d", "--database",
	help="specifies the database", default="TestDB")
parser.add_option("-f", "--diff_table",
	help="specifies the table in which changes are stored", default="changes")
parser.add_option("-u","--current_table",
	help="specifies table in which current csv is to be imported", default="MITSUBISHI_Customer_RDR_for_Ocean_current")
parser.add_option("-p","--previous_table",
	help="specifies table in which previous csv is to be imported", default="MITSUBISHI_Customer_RDR_for_Ocean_previous")

options, arguments = parser.parse_args()
DIFF_TB_NAME = options.diff_table
DB_NAME = options.database
CURR_TB_NAME = options.current_table
PREV_TB_NAME = options.previous_table
conn = pyodbc.connect("Trusted_Connection=yes;DRIVER={SQL Server Native Client 10.0};SERVER=localhost;DATABASE=" + DB_NAME + ";")
cursor = conn.cursor()
select_sql = "select curr.ContactID AS ContactID, prev.ContactID AS pContactID, curr.FirstName, curr.LastName, curr.Address1 AS NewAddress1, curr.Address2 AS NewAddress2\
,curr.City AS NewCity, curr.State AS NewState, curr.ZipCode AS NewZip,prev.Address1 AS OldAddress1, prev.Address2 AS OldAddress2,\
 prev.City AS OldCity,prev.State AS OldState, prev.ZipCode AS OldZip from " + DB_NAME + ".dbo." + CURR_TB_NAME + " AS curr \
LEFT OUTER JOIN " + DB_NAME + ".dbo." + PREV_TB_NAME + " AS prev ON curr.ContactID = prev.ContactID"
cursor.execute(select_sql)
rows = cursor.fetchall()
if cursor.tables(table=DIFF_TB_NAME).fetchone():
	print ""
else:
	create_sql = "create table " + DIFF_TB_NAME + " (ContactID varchar(8000),FirstName varchar(8000), LastName varchar(8000),\
		Status varchar(8000), NewAddress1 varchar(8000), NewAddress2 varchar(8000), NewCity varchar(8000),\
	 NewState varchar(8000), NewZip varchar(8000), OldAddress1 varchar(8000), OldAddress2 varchar(8000)\
	 , OldCity varchar(8000), OldState varchar(8000), OldZip varchar(8000))"
	cursor.execute(create_sql)
	cursor.commit()
changed_rows = []
if rows:
	for row in rows:
		if row.NewAddress1 != row.OldAddress1 or row.NewAddress2 != row.OldAddress2 or row.NewState != row.OldState or row.NewCity != row.OldCity or row.NewZip != row.OldZip:
			if row.pContactID == None:
				status = "New"
			else:
				status = "Address Changed"
			cursor.execute("insert into " + DIFF_TB_NAME + " values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", row.ContactID, row.FirstName,
				row.LastName, status, row.NewAddress1, row.NewAddress2,row.NewCity , row.NewState, row.NewZip, row.OldAddress1, row.OldAddress2,
				row.OldCity, row.OldState, row.OldZip)
			cursor.commit()
			
conn.commit()
conn.close()