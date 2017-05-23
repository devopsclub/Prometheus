#!/bin/bash
# Prometheus & exporters install script

echo "Prometheus & al install script"

echo "This script installs Prometheus, node_exporter, mysql_exporter, nginx_exporter, redis_exporter, elastic_exporter"

read -p "You will need your root MYSQL password. Continue (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  echo " -> Starting Script ... ";
else
  echo "Skipped. Have a nice day."
  exit 0
fi

sudo apt-get update
sudo apt-get install prometheus
sudo apt-get install prometheus-node-exporter

cat <<EOT>> /etc/prometheus/prometheus.yml
#Setup Prometheus.yml

global:
 scrape_interval: 10spr
 evaluation_interval: 5s

#Prometheus
scrape_configs:
  - job_name: "prometheus"
    scrape_interval: "5s"
    static_configs:
    - targets: ['localhost:9090']

#Node exports
scrape_configs:
  - job_name: "node"
    scrape_interval: "5s"
    static_configs:
    - targets: ['localhost:9100']

# Redis
scrape_configs:
	- job_name: redis_exporter
	  static_configs:
	  - targets: ['localhost:9121']

# MySQL
scrape_configs:
 - job_name: 'mysqld'
   static_configs:
   - targets: ['localhost:9099']

# FPM
scrape_configs:
  - job_name: 'fpm'
    static_configs:
    - targets: ['localhost:9099']

# NGINX
scrape_configs:
  - job_name: 'nginx'
    static_configs:
    - targets: ['localhost:9113']

# Elastic
scrape_configs:
  - job_name: 'elastic'
    static_configs:
    - targets: ['localhost:9108']

EOT

echo “ -> Configured prometheus.yml ...”

sudo apt-get install golang

# Set Go variables
mkdir ~/go
mkdir ~/logs

cat <<EOT>> /etc/profile.d/goenv.sh
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOT

source /etc/profile.d/goenv.sh


go get www.github.com/oliver006/redis_exporter.git

cd ~/go/src/github.com/oliver006/redis_exporter

go get

go build

echo " -> Redis exporter installed ..."

# RUN REDIS:
# cd ~/go/src/github.com/oliver006/redis_exporter
# ./redis_exporter

go get -u github.com/justwatchcom/elasticsearch_exporter

cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter

go get

go build

echo " -> ElasticSearch exporter installed ..."

# RUN ELASTIC:
# cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter
# ./elasticsearch_exporter


# MYSQL COMMANDS:
# CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'XXXXXXXX' WITH MAX_USER_CONNECTIONS 3;
# GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';

# /var/www/current/.env for mysql passwords

echo "Please enter root user MySQL password: (leave blank to skip) ----- "

read rootpasswd

if [ -n "$rootpasswd" ]; then
  mysql -uroot -p${rootpasswd} -e "# CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'PrometheusSQLexporter' WITH MAX_USER_CONNECTIONS 3;
"
  mysql -uroot -p${rootpasswd} -e "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';"

  # Run: ./mysqld_exporter

  go get -u github.com/prometheus/mysqld_exporter

  cd ~/go/src/github.com/prometheus/mysqld_exporter

  go get

  go build

  echo " -> This will take a while ... "

  make

  echo " -> MYSQL exporter installed ..."

else
    echo "MYSQL_exporter will not be installed ..."
fi

go get -u github.com/discordianfish/nginx_exporter

cd ~/go/src/github.com/discordianfish/nginx_exporter

go get

go build

echo " -> NGINX exporter installed ..."

# TO RUN:
# cd ~/go/src/github.com/discordianfish/nginx_exporter
# ./nginx_exporter

cd ~/

git clone https://github.com/craigmj/phpfpm_exporter

cd phpfpm_exporter/

./build.sh

echo " -> PHPFM exporter installed ..."

# TO RUN 
# cd phpfpm_exporter/bin/
# ./phpfpm_exporter --listen.address=localhost:9099 {PHPFORM URL}

## Start all servers

#cat <<EOT>> /etc/init/prometheus_server_start.conf

cat <<EOT>> /etc/systemd/system/prometheus-server.service

[Unit]
After=mysql.service

[Service]
ExecStart=/usr/local/bin/prometheus-server.sh

[Install]
WantedBy=default.target

EOT

cat <<EOT>> /usr/local/bin/prometheus-server.sh
#!/bin/sh

cd ~/phpfpm_exporter/bin/
sudo nohup ./phpfpm_exporter --listen.address=localhost:9099 {PHPFORM URL} > ~/logs/phpfm_exporter.log 2>&1 &

cd ~/go/src/github.com/oliver006/redis_exporter

sudo nohup ./redis_exporter > ~/logs/redis_exporter.log 2>&1 &

cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter

sudo nohup ./elasticsearch_exporter > ~/logs/elasticsearch_exporter.log 2>&1 &

cd ~/go/src/github.com/discordianfish/nginx_exporter

sudo nohup ./nginx_exporter > ~/logs/nginx_exporter.log 2>&1 &

cd ~/go/src/github.com/prometheus/mysqld_exporter

sudo nohup ./mysqld_exporter > ~/logs/mysqld_exporter.log 2>&1 &

EOT

chmod 744 /usr/local/bin/prometheus-server.sh

chmod 664 /etc/systemd/system/prometheus-server.service

systemctl daemon-reload

systemctl enable prometheus-server.service

systemctl start prometheus-server.service

# sudo ln -f -s /etc/init/prometheus_server_start.conf /etc/init.d/prometheus_server_start

echo " -> Script finished. Have a nice day."


