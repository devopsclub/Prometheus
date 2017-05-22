#!/bin/bash
# MYSQL export Install Script
cd ~/Downloads

wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.9.0/mysqld_exporter-0.9.0.linux-amd64.tar.gz

tar -xzf mysqld_exporter-0.9.0.linux-amd64.tar.gz

export

DATA_SOURCE_NAME='mysqld_exporter:a_password@unix(/var/run/mysqld/mysqld.sock)/'
./mysqld_exporter
