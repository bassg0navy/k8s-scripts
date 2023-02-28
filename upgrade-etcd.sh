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

# Move binaries to PATH
sudo mv /tmp/etcd-download-test/etcd* /usr/local/bin/

# Restart etcd
{   sudo systemctl daemon-reload;   sudo systemctl enable etcd;   sudo systemctl start etcd; }

# Verify etcd is running
sudo systemctl status etcd

# Verify etcd versions
UPGRADE_VERSION=$(echo $ETCD_VER | sed 's/^.//') # Remove 'v' prefix from $ETCD_VER
CURRENT_VERSION=$(etcd --version | (read var1 var2 var3; echo $var3))
CURRENT_ETCDCTL_VERSION=$(etcdctl version)

echo -e "\nUpgrade version: $UPGRADE_VERSION"
echo "Current version: $CURRENT_VERSION"
echo "$CURRENT_ETCDCTL_VERSION"

# If Statement to Compare ETCD Versions
if [[ $UPGRADE_VERSION == $CURRENT_VERSION ]]
then
        echo -e "\n Upgrade Successful! 👍🏽  \n"
else
        echo -e "\n Upgrade Unsuccessful 💩 \n"
fi

