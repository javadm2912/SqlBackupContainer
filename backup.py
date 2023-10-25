import pyodbc
from datetime import date
import subprocess

username, password, server, database = input().split()

connection = pyodbc.connect(driver='{ODBC Driver 17 for SQL Server}',
                            server=server, uid=username, pwd=password, autocommit=True)

today = date.today().strftime('%Y-%m-%d')
backup = "BACKUP DATABASE [{0}] TO DISK = N'/home/data/{0}-{1}.bak'".format(
    database, today)
cursor = connection.cursor().execute(backup)
while cursor.nextset():
    pass
connection.close()

subprocess.call(["tar", "-zcvf", "/home/backups/{0}-{1}.tar.gz".format(
    database, today), "/home/sqldata/{0}-{1}.bak".format(database, today)])

subprocess.call(["rm", "/home/sqldata/{0}-{1}.bak".format(database, today)])