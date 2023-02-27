#!/bin/bash

ETCD_VER=v3.4.16

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

# Download upgrade binaries
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

# Verify new version
/tmp/etcd-download-test/etcd --version
/tmp/etcd-download-test/etcdctl version

# mv binaries to PATH
sudo mv /tmp/etcd-download-test/etcd* /usr/local/bin/

# Restart etcd service
{   sudo systemctl daemon-reload;   sudo systemctl enable etcd;   sudo systemctl start etcd; }

# Verify etcd service is running
sudo systemctl status etcd

# Verify etcd versions
etcdctl version
etcd --version
