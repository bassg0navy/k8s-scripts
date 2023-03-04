#!/bin/bash

K8S_VERSION="v1.24.0"
CONTROLLER_SERVICES=(kube-apiserver kube-controller-manager kube-scheduler kubectl)

# Choose either URL
GOOGLE_URL=https://storage.googleapis.com
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64

# Download binaries
for service in "${CONTROLLER_SERVICES[@]}";
do 
    wget -q --show-progress --https-only --timestamping ${DOWNLOAD_URL}/$service
done

# Install binaries to /usr/local/bin
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

# Start controller services
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl restart kube-apiserver kube-controller-manager kube-scheduler
#sudo systemctl status kube-apiserver kube-controller-manager kube-scheduler

# Verify versions
for service in kube-apiserver kube-controller-manager kube-scheduler;
do
	{$service}version=$service --version
    echo ${service}_version
    echo ${kube-apiserver_version}
done
kubectl version
#kube-apiserver version; kube-controller-manager version; kube-scheduler version; kubectl version

