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

source /etc/profile.d/goenv.sh