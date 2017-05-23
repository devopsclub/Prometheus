#!/bin/bash
# Prometheus Install Script

echo "Starting servers..."

cd ~/Prometheus/servers/
sudo nohup ./prometheus > prometheus.log 2>&1 &

echo "Prometheus up..."

cd ~/Prometheus/node_exporter/

sudo nohup ./node_exporter > node_exporter.log 2>&1 &

cd ~/other_src/gopath/bin

sudo nohup ./elasticsearch_exporter > elastic.log 2>&1 &

sudo nohup ./redis_exporter > redis.log 2>&1 &


./mysqld_exporter
