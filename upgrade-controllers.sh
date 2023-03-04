#!/bin/bash

K8S_VERSION="v1.24.0"
CONTROLLER_SERVICES=(kube-apiserver kube-controller-manager kube-scheduler kubectl)

# Choose either URL
GOOGLE_URL=https://storage.googleapis.com
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64

# Download binaries
for service in $CONTROLLER_SERVICES;
do 
    wget -q --show-progress --https-only --timestamping \
    ${DOWNLOAD_URL}/${service}
    # Clear tmp dir
    # rm -f /tmp/${service}-${K8S_VERSION}-linux-amd64.tar.gz \
    # rm -rf /tmp/${service}-download-test && mkdir -p /tmp/${service}-download-test
done

# Install binaries to /usr/local/bin
{
  chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
  sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
}

# Start controller services
{
  sudo systemctl daemon-reload
  sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
  sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
}

# wget -q --show-progress --https-only --timestamping \
#   ${DOWNLOAD_URL}/kube-apiserver \
#   ${DOWNLOAD_URL}/kube-controller-manager \
#   ${DOWNLOAD_URL}/kube-scheduler \
#   ${DOWNLOAD_URL}/kubectl
