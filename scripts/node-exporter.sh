#!/usr/bin/env bash
set -euo pipefail

VERSION=1.8.2
ARCH=linux-amd64

mkdir -p /tmp/node_exporter
cd /tmp/node_exporter || { echo "ERROR! No /tmp found.."; exit 1; }

wget "https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.${ARCH}.tar.gz" \
    -O /tmp/node_exporter.tar.gz

tar xfz /tmp/node_exporter.tar.gz -C /tmp/node_exporter || { echo "ERROR! Extracting the node_exporter tar"; exit 1; }

sudo cp "/tmp/node_exporter/node_exporter-${VERSION}.${ARCH}/node_exporter" "/usr/local/bin"
sudo useradd node_exporter --no-create-home --shell /bin/false
sudo chown node_exporter:node_exporter "/usr/local/bin/node_exporter"

sudo bash -c 'cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter.service