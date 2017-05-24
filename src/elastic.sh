#!/bin/bash

go get -u github.com/justwatchcom/elasticsearch_exporter

cd ~/go/src/github.com/justwatchcom/elasticsearch_exporter

go get

go build

echo " -> ElasticSearch exporter installed ..."