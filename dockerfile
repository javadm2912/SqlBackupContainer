#latest ubuntu now is 22.04
FROM ubuntu:latest

#Installing prerequisite libraries
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y python3.10
RUN apt-get install -y pip
RUN pip install pyodbc
RUN apt-get install -y cron
RUN apt-get install -y tar
RUN apt-get install -y nano

#Installing the SQL database connection tool
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#If using another version of ubuntu change folloing line version
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN exit
RUN apt-get update && apt install -y apt-utils
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get remove -y libodbc2 libodbcinst2 odbcinst unixodbc-common
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN apt-get install -y unixodbc-dev

#Set time zone for using in cron
RUN apt-get update && apt-get install -y tzdata
ENV TZ="Asia/Tehran"

#Copy python script and add execute access
COPY ./backup.py /home/scripts/backup.py
RUN chmod 777  /home/scripts/backup.py

#Copy backup shell script and add execute access
COPY ./backup.sh /home/scripts/backup.sh
RUN chmod 777 /home/scripts/backup.sh

#Copy crontab and add execute access
COPY ./backupCron /home/scripts/backupCron
RUN chmod 0644 /home/scripts/backupCron

#Adding tab to the cron
RUN crontab /home/scripts/backupCron

#Create logfile
RUN touch /var/log/cron.log
CMD cron && tail -f /var/log/cron.log