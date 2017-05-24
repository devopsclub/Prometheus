#!/bin/bash


cat <<EOT > /etc/prometheus/prometheus.yml
#Setup Prometheus.yml

global:
 scrape_interval: 10s
 evaluation_interval: 5s

#Prometheus
scrape_configs:
  - job_name: "prometheus"
    scrape_interval: "5s"
    target_groups:
    - targets: ['localhost:9090']

#Node exports
scrape_configs:
  - job_name: "node"
    scrape_interval: "5s"
    target_groups:
    - targets: ['localhost:9100']

# Redis
scrape_configs:
  - job_name: redis_exporter
    target_groups:
    - targets: ['localhost:9121']

# MySQL
scrape_configs:
 - job_name: 'mysqld'
   target_groups:
   - targets: ['localhost:9104']

# FPM
scrape_configs:
  - job_name: 'fpm'
    target_groups:
    - targets: ['localhost:9099']

# NGINX
scrape_configs:
  - job_name: 'nginx'
    target_groups:
    - targets: ['localhost:9113']

# Elastic
scrape_configs:
  - job_name: 'elastic'
    target_groups:
    - targets: ['localhost:9108', 'localhost:9090', 'localhost:9113','localhost:9099', 'localhost:9104', 'localhost:9121', 'localhost:9100']

EOT