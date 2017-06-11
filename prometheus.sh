#!/bin/bash
# Prometheus & exporters install script

echo "Prometheus & al install script"

echo "This script installs Prometheus, node_exporter, mysql_exporter, nginx_exporter, redis_exporter, elastic_exporter"


# NGINX conf: access_log syslog:server=127.0.0.1:9514 prometheus;

read -p "Install prometheus, node_exporter? (y/n)" PROMETHEUS
if [ "$PROMETHEUS" = "y" ]; then

sudo apt-get update
sudo apt-get install prometheus
sudo apt-get install prometheus-node-exporter

cat <<EOT > /etc/prometheus/prometheus.yml
# Sample config for Prometheus.

global:
  scrape_interval:     5s # By default, scrape targets every 15 seconds.
  evaluation_interval: 5s # By default, scrape targets every 15 seconds.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'example'

# Load and evaluate rules in this file every 'evaluation_interval' seconds.
rule_files:
  # - "first.rules"
  # - "second.rules"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
    scrape_timeout: 10s


    target_groups:
      - targets: ['localhost:9090']

  - job_name: 'node'
    target_groups:
      - targets: ['localhost:9100']

  - job_name: 'redis_exporter'
    target_groups:
      - targets: ['localhost:9121']

  - job_name: 'mysqld'
    target_groups:
      - targets: ['localhost:9104']

  - job_name: 'fpm'
    target_groups:
      - targets: ['localhost:9099']

  - job_name: 'nginx'
    target_groups:
      - targets: ['localhost:9147']

  - job_name: 'apache'
    target_groups:
      - targets: ['localhost:9117']

  - job_name: 'elastic'
    target_groups:
      - targets: ['localhost:9108']
EOT

echo “ -> Configured prometheus ...”
else
echo "Skipping prometheus, node_exporter install."
fi


# Setup prometheus server service

cat <<EOT > /etc/systemd/system/prometheus-server.service

[Unit]
After=mysql.service

[Service]
ExecStart=/usr/bin/prometheus
Restart=always

[Install]
WantedBy=default.target

EOT

chmod 664 /etc/systemd/system/prometheus-server.service

read -p "Install GoLang? (y/n) - required for most exporters" GO
if [ "$GO" = "y" ]; then
# sh ./src/go.sh

#!/bin/bash
sudo apt-get install golang

# Set Go variables
mkdir ~/go
mkdir ~/logs

cat <<EOT > /etc/profile.d/goenv.sh
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOT

export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

source /etc/profile.d/goenv.sh

echo “ -> Configured Golang ...”
else
echo "Skipping golang install."
fi

read -p "Install Apache exporter? (y/n)" APACHE
if [ "$APACHE" = "y" ]; then

go get github.com/neezgee/apache_exporter

cd ~/go/src/github.com/neezgee/apache_exporter

go get

go build


cat <<EOT >> /usr/local/bin/prometheus-server.bash

cd ~/go/src/github.com/neezgee/apache_exporter

sudo nohup ./apache_exporter > ~/logs/apache_exporter.log 2>&1 &


EOT


echo “ -> Configured Apache ...”
else
echo "Skipping apache_exporter install."
fi


read -p "Redis password: (Enter to skip redis_exporter)" REDISPASS
if [ "$REDISPASS" != "" ]; then

echo "Installing redis_exporter..."

go get www.github.com/oliver006/redis_exporter.git

cd ~/go/src/github.com/oliver006/redis_exporter

go get

go build

cat <<EOT >> /usr/local/bin/prometheus-server.bash

cd ~/go/src/github.com/oliver006/redis_exporter

sudo nohup ./redis_exporter --redis.password "${REDISPASS}" > ~/logs/redis_exporter.log 2>&1 &

EOT

echo " -> Redis exporter installed ..."

else

echo "Skipping redis_exporter installation."

fi


read -p "MySQL root password: (Enter to skip MYSQL setup)" MYSQLPASS
if [ "$MYSQLPASS" != "" ]; then

mysql -uroot -p${MYSQLPASS} -e "CREATE USER 'mysqlexporter' IDENTIFIED BY 'test' WITH MAX_USER_CONNECTIONS 3;"
mysql -uroot -p${MYSQLPASS} -e "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqlexporter';"
mysql -uroot -p${MYSQLPASS} -e "FLUSH PRIVILEGES;"

else

echo "Skipping mySQL setup."

fi


read -p "Install mysql_exporter? (y/n)" MYSQL
if [ "$MYSQL" = "y" ]; then
echo "Installing mysql_exporter..."

go get -u github.com/prometheus/mysqld_exporter

cd ~/go/src/github.com/prometheus/mysqld_exporter

go get

go build

export DATA_SOURCE_NAME='mysqlexporter:test@unix(/var/run/mysqld/mysqld.sock)/'

cat <<EOT >> ~/.bashrc

export DATA_SOURCE_NAME='mysqlexporter:test@unix(/var/run/mysqld/mysqld.sock)/'

EOT

source ~/.bashrc

echo " -> This will take a while ... "

make

cat <<EOT >> /usr/local/bin/prometheus-server.bash

cd ~/go/src/github.com/prometheus/mysqld_exporter

sudo nohup ./mysqld_exporter --config.my-cnf=/etc/mysql/my.cnf > /dev/null 2>&1 &

EOT

echo " -> MYSQL exporter installed ..."

else

echo "Skipping mySQL installation."

fi


read -p "Install nginx_exporter? (y/n)" NGINX
if [ "$NGINX" = "y" ]; then

go get github.com/markuslindenberg/nginx_request_exporter

cd ~/go/src/github.com/markuslindenberg/nginx_request_exporter

go get

go build

echo " -> NGINX exporter installed ..."

cat <<EOT >> /usr/local/bin/prometheus-server.bash

cd ~/go/src/github.com/markuslindenberg/nginx_request_exporter

sudo nohup ./nginx_request_exporter > ~/logs/nginx_exporter.log 2>&1 &

EOT

else

echo "Skipping nginx installation."

fi

read -p "Install phpfm_exporter? (y/n)" PHPFM
if [ "$PHPFM" = "y" ]; then

cd ~/

git clone https://github.com/craigmj/phpfpm_exporter

cd phpfpm_exporter/

./build.sh

echo " -> PHPFM exporter installed ..."

cat <<EOT >> /usr/local/bin/prometheus-server.bash

cd ~/phpfpm_exporter/bin/

sudo nohup ./phpfpm_exporter --listen.address=localhost:9099 {PHPFORM URL} > ~/logs/phpfm_exporter.log 2>&1 &

EOT

else
 	echo "Skipping phpfm installation."
fi


read -p "Install elastic_exporter services? (y/n)" ELASTIC
if [ "$ELASTIC" = "y" ]; then

go get -u github.com/justwatchcom/elasticsearch_exporter

cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter

go get

go build

echo " -> ElasticSearch exporter installed ..."

cat <<EOT >> /usr/local/bin/prometheus-server.bash

cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter

sudo nohup ./elasticsearch_exporter > ~/logs/elasticsearch_exporter.log 2>&1 &

EOT
else

echo "Skipping elastic_exporter installation."

fi

systemctl enable prometheus-server.service
systemctl daemon-reload
systemctl start prometheus-server.service

killall -9 prometheus

echo " -> Script finished. Have a nice day."
