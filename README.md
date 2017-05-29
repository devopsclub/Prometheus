# Prometheus
Install script for Prometheus service monitoring tool

* Prometheus
* Node exporter
* MySQL exporter
* Apache exporter
* ElasticSearch exporter
* Redis exporter
* Nginx exporter (in progress)
* PHPFM exporter (in progress)


## Setup MYSQL & Apache

In MySQL:

CREATE USER 'mysqlexporter' IDENTIFIED BY 'test' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqlexporter';
mysql -uroot -p${MYSQLPASS} -e "FLUSH PRIVILEGES;"

add lines to /etc/apache2/mods-available/status.conf :

   <Location /server-status>

    Allow from 127.0.0.1
  
    Allow from localhost
  
   < / Location>
   
**COMMENT OUT require local inside <location /server-status > **

run:

**service apache2 graceful**

## Run file:

git clone this repo

**chmod 755 ./prometheus.sh**

**sudo ./prometheus.sh**


Press y/n for selection - always select prometheus & node exporter, also GoLang for most exporters.



