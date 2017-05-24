#!/bin/bash
# Prometheus & exporters install script

echo "Prometheus & al install script"

echo "This script installs Prometheus, node_exporter, mysql_exporter, nginx_exporter, redis_exporter, elastic_exporter"

cd ~/Prometheus/src/

chmod 777 elastic.sh
chmod 777 go.sh
chmod 777 mysql.sh
chmod 777 nginx.sh
chmod 777 phpfm.sh
chmod 777 prometheus-server.sh
chmod 777 prometheus.sh

cd ~/


read -p "Install prometheus, node_exporter? (y/n)" PROMETHEUS
if [ "$PROMETHEUS" = "y" ]; then

sudo apt-get update
sudo apt-get install prometheus
sudo apt-get install prometheus-node-exporter

sh ./src/prometheus.sh

cat <<EOT >> /usr/local/bin/prometheus-server.sh

cd /usr/bin

sudo nohup ./prometheus > ~/logs/prometheus.log 2>&1 &

EOT

echo “ -> Configured prometheus ...”
else
echo "Skipping prometheus, node_exporter install."
fi


# Setup prometheus server service
sh ./src/prometheus-server.sh

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


read -p "Redis password: (Enter to skip redis_exporter)" REDISPASS
if [ "$REDISPASS" != "" ]; then

echo "Installing redis_exporter..."

go get www.github.com/oliver006/redis_exporter.git

cd ~/go/src/github.com/oliver006/redis_exporter

go get

go build

cat <<EOT >> /usr/local/bin/prometheus-server.sh

cd ~/go/src/github.com/oliver006/redis_exporter

sudo nohup ./redis_exporter --redis.password "${REDISPASS}" > ~/logs/redis_exporter.log 2>&1 &

EOT

echo " -> Redis exporter installed ..."

else
 
echo "Skipping redis_exporter installation."

fi


read -p "MySQL root password: (Enter to skip mysql_exporter)" MYSQLPASS
if [ "$MYSQLPASS" != "" ]; then
echo "Installing mysql_exporter..."

mysql -uroot -p${MYSQLPASS} -e "CREATE USER 'mysqlexporter' IDENTIFIED BY 'test' WITH MAX_USER_CONNECTIONS 3;"
mysql -uroot -p${MYSQLPASS} -e "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqlexporter';"
mysql -uroot -p${MYSQLPASS} -e "FLUSH PRIVILEGES;"

export DATA_SOURCE_NAME='mysqlexporter:test@unix(/var/run/mysqld/mysqld.sock)/'

go get -u github.com/prometheus/mysqld_exporter

cd ~/go/src/github.com/prometheus/mysqld_exporter

go get

go build

echo " -> This will take a while ... "

make

cat <<EOT >> /usr/local/bin/prometheus-server.sh

cd ~/go/src/github.com/prometheus/mysqld_exporter

sudo nohup ./mysqld_exporter > ~/logs/mysqld_exporter.log 2>&1 &

EOT

echo " -> MYSQL exporter installed ..."

else
 	
echo "Skipping mySQL installation."

fi


read -p "Install nginx_exporter? (y/n)" NGINX
if [ "$NGINX" = "y" ]; then

sh ./src/nginx.sh

cat <<EOT >> /usr/local/bin/prometheus-server.sh

sudo nohup ./nginx_exporter > ~/logs/nginx_exporter.log 2>&1 &

cd ~/go/src/github.com/prometheus/mysqld_exporter

EOT

else
 
echo "Skipping nginx installation."

fi

read -p "Install phpfm_exporter? (y/n)" PHPFM
if [ "$PHPFM" = "y" ]; then

sh ./src/phpfm.sh

cat <<EOT >> /usr/local/bin/prometheus-server.sh

cd ~/phpfpm_exporter/bin/

sudo nohup ./phpfpm_exporter --listen.address=localhost:9099 {PHPFORM URL} > ~/logs/phpfm_exporter.log 2>&1 &

EOT

else
 	echo "Skipping phpfm installation."
fi


read -p "Install elastic_exporter services? (y/n)" ELASTIC
if [ "$ELASTIC" = "y" ]; then

sh ./src/elastic.sh

cat <<EOT >> /usr/local/bin/prometheus-server.sh

cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter

sudo nohup ./elasticsearch_exporter > ~/logs/elasticsearch_exporter.log 2>&1 &

EOT
else

echo "Skipping elastic_exporter installation."

fi


systemctl daemon-reload

systemctl enable prometheus-server.service

systemctl start prometheus-server.service


echo " -> Script finished. Have a nice day."