#!/bin/bash

JENKINS_DIR=jenkins_home
PROM_DIR=prometheus_home
NFS_DIR=/var/nfs

sudo groupadd -g 1000 jenkins
sudo groupadd -g 2000 prometheus
sudo useradd -u 1000 -g 1000 -m -s /bin/nologin jenkins
sudo useradd -u 2000 -g 2000 -m -s /bin/nologin prometheus


sudo apt install nfs-kernel-server -y
sudo systemctl enable --now nfs-server


sudo mkdir -p ${NFS_DIR}/{${JENKINS_DIR},${PROM_DIR}
sudo chown -R nobody:nogroup ${NFS_DIR}
echo '${NFS_DIR}/${JENKINS_DIR} *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports
echo '${NFS_DIR}/${PROM_DIR} *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports

sudo exportfs -ar