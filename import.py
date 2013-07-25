import csv
import re
import pyodbc
import os
import time
import sys
FORMAT_BUFFER = "format_file.fmt"
TEXT_QUALIFIER = "\""
FIELD_DELIM = "|"
ROW_DELIM = "\\n"
HEADER = True
CSV_BUFFER = "temp_csv_buffer.csv"
CSV_FILE = "input/MITSUBISHI_Customer_RDR_for_Ocean.previous.csv"
# CSV_FILE = raw_input("Enter the name or the complete path of the csv you want to import : ")
DB_NAME = "TestDB"
TB_NAME = "MITSUBISHI_Customer_RDR_for_Ocean_previous"
if CSV_FILE[-3:] != "csv":
	CSV_FILE += ".csv"
with open(CSV_FILE, "r") as infile:
	reader = csv.reader(infile, delimiter=FIELD_DELIM)
	for row in reader:
		break
	# DB_NAME = raw_input("Enter the DB name[for now the localhost is used as the server] : ")
	conn = pyodbc.connect("Trusted_Connection=yes;DRIVER={SQL Server Native Client 10.0};SERVER=localhost;DATABASE=" + DB_NAME + ";")
	cursor = conn.cursor()
	# TB_NAME = raw_input("Enter the name of the table to be created : ")
	if cursor.tables(table=TB_NAME).fetchone():
		response = raw_input("This table already exits do you want to delete it or exit the program (d,e):")
		if response.lower() == 'd':
			if raw_input("Are you sure (y,n)").lower() == 'y':
				cursor.execute("drop table " + DB_NAME + ".dbo." + TB_NAME)
				cursor.commit()
			else:
				sys.exit()
		elif response.lower() == 'e':
			sys.exit()
		else:
			print "Invalid option exiting..."
			time.sleep(3)
			sys.exit()
	create_sql = "CREATE TABLE " + TB_NAME + "("
	for col in row:
		create_sql += col + " varchar(8000), "
	create_sql = create_sql[:-2] + ")"
	create_sql = create_sql.replace("Utility Opt In","Utility_Opt_In")
	print create_sql
	cursor.execute(create_sql)
	conn.commit()
	conn.close()

	reader = open(CSV_FILE, "r").read()
	temp = re.sub(TEXT_QUALIFIER,'', reader)
	if HEADER:
		temp = temp.split(ROW_DELIM.decode("string_escape"), 1)[1]
	open(CSV_BUFFER, "w").write(temp)

	bcp_create_format = "bcp "+ DB_NAME + ".dbo." + TB_NAME + " format nul -T -c -t \"" + FIELD_DELIM + "\" -r \"" + ROW_DELIM + "\" -f " + FORMAT_BUFFER
	# print bcp_create_format
	os.system(bcp_create_format)
	os.system("sed 's/Utility Opt In/Utility_Opt_In/g' " + FORMAT_BUFFER)
	bcp_import = "bcp " + DB_NAME + ".dbo." + TB_NAME + " in " + CSV_BUFFER + " -f " + FORMAT_BUFFER + " -T"
	os.system(bcp_import)
	remove_buffers = "rm " + CSV_BUFFER + " " + FORMAT_BUFFER
	os.system(remove_buffers)