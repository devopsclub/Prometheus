#!/bin/bash
# Go Install Script

cd /tmp

wget https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf  go1.8.1.linux-amd64.tar.gz

export GOROOT=/usr/local/go
export PATH=${GOROOT}/bin:${PATH}
export GOPATH=${HOME}/other_src/gopath
export PATH=${GOPATH}/bin:${PATH}

source ~/.bashrc

go get -v -t ./...
