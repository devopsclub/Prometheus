#!/bin/bash
# main Install Script

echo “-> Starting Package Install . . .  ”

sh ./prometheus.sh
echo “-> Prometheus install successful . . .  ”

sh ./go.sh
echo “-> GoInstall successful. . .  ”

sh ./redis.sh
echo “-> RedisInstall successful. . .  ”

sh ./mysql.sh
echo “-> MYSQL install successful . . . ”

sh ./phpfm.sh
echo “-> phpFM successful . . .  ”

sh ./elastic.sh
echo “-> Elastic install successful . . .  ”

sh ./startservers.sh
echo “-> Servers started! Good to go boys! :)”
