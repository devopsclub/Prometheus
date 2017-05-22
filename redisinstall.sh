#!/bin/bash
# Redis export Install Script
cd ~/Downloads

git clone https://github.com/oliver006/redis_exporter.git

cd ~/

go get -v -t ./...

cd ~/Downloads/redis_exporter/

./build.sh

go build
