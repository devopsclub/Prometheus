#!/bin/bash

cat <<EOT > /etc/systemd/system/prometheus-server.service

[Unit]
After=mysql.service

[Service]
ExecStart=/usr/local/bin/prometheus-server.sh

[Install]
WantedBy=default.target

EOT

cat <<EOT > /usr/local/bin/prometheus-server.sh
#!/bin/sh


EOT

chmod 744 /usr/local/bin/prometheus-server.sh

chmod 664 /etc/systemd/system/prometheus-server.service