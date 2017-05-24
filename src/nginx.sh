#!/bin/bash

go get -u github.com/discordianfish/nginx_exporter

cd ~/go/src/github.com/discordianfish/nginx_exporter

go get

go build

echo " -> NGINX exporter installed ..."