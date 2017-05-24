#!/bin/bash
cd ~/

git clone https://github.com/craigmj/phpfpm_exporter

cd phpfpm_exporter/

./build.sh

echo " -> PHPFM exporter installed ..."