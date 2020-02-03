#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
apt-get -q update
apt-get -yq install apache2

tee /etc/consul.d/webserver-80.json > /dev/null <<"EOF"
{
  "service": {
    "id": "webserver-80",
    "name": "webserver",
    "tags": ["apache"],
    "port": 80,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 80",
        "tcp": "localhost:80",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "http",
        "name": "HTTP on port 80",
        "http": "http://localhost:80/",
        "interval": "30s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "apache service",
        "args": ["systemctl", "status", "apache2.service"],
        "interval": "60s"
      }
    ]
  }
}
EOF

consul reload