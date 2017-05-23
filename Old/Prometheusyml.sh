#!/bin/bash
# Prepare prometheus.yml

cat <<EOT>> ~/Prometheus/server/prometheus.yml
#Setup Prometheus.yml

global:
 scrape_interval: 10s
 evaluation_interval: 10s

#MySQL
scrape_configs:
 - job_name: 'mysqld'
   static_configs:
    - targets:
      - localhost:9104

#Node exports
scrape_configs:
  - job_name: "node"
    scrape_interval: "15s"
    static_configs:
    - targets: ['localhost:9100']

#Prometheus
scrape_configs:
  - job_name: "prometheus"
    scrape_interval: "15s"
    static_configs:
    - targets: ['localhost:9090']

# Redis
- job_name: redis_exporter
  static_configs:
  - targets: ['localhost:9121']

# Elastic search : 9108

# 9200 ???

EOT

echo “ -> Configured prometheus.yml ”
