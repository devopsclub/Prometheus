#!/bin/bash
# Prometheus Install Script

echo “Starting Prometheus Install…”

mkdir ~/Downloads
cd Downloads

wget https://github.com/prometheus/prometheus/releases/download/v1.6.3/prometheus-1.6.3.linux-amd64.tar.gz

echo “Downloaded Prometheus…”

mkdir -p ~/Prometheus/

cd ~/Prometheus

sudo tar -xvzf ~/Downloads/prometheus-1.6.3.linux-amd64.tar.gz

echo “Extracted Prometheus Tarball”

mv prometheus-1.6.3.linux-amd64 server

cd ~/Downloads/

sudo wget https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz

echo “Downloaded Node exporter…”

cd ~/Prometheus/

sudo tar -xvzf ~/Downloads/node_exporter-0.14.0.linux-amd64.tar.gz

echo “Extracted Node_exporter Tarball”

sudo mv node_exporter-0.14.0.linux-amd64 node_exporter

sudo ln -s ~/Prometheus/node_exporter/node_exporter /usr/bin

echo “Linked Node_exporter”

sudo echo 'start on startup'  >> /etc/init/node_exporter.conf
sudo echo 'script' >> /etc/init/node_exporter.conf
sudo echo '    /usr/bin/node_exporter' >> /etc/init/node_exporter.conf
sudo echo 'end script' >> /etc/init/node_exporter.conf

echo “Node_exporter service setup…”

sh ./prometheusyml.sh

cd ~/Prometheus/server/

sudo chmod 777 ~/Prometheus/server/prometheus.log

sudo chmod 777 ~/Prometheus/server/prometheus.yml

sudo nohup ./prometheus > prometheus.log 2>&1 &

echo “Done!”

sudo /usr/bin/node_exporter
