#!/bin/bash

K8S_VERSION="v1.24.0"
CONTROLLER_SERVICES=(kube-apiserver kube-controller-manager kube-scheduler kubectl)
NEW_LINE=$(echo -e "\n")

# Choose either URL
GOOGLE_URL=https://storage.googleapis.com
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64

# Download binaries
for service in "${CONTROLLER_SERVICES[@]}";
do 
    wget -q --show-progress --https-only --timestamping ${DOWNLOAD_URL}/$service
done

# Install binaries
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

# Start controller services
sudo systemctl daemon-reload && \
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler && \
sudo systemctl restart kube-apiserver kube-controller-manager kube-scheduler && \
sudo systemctl status kube-apiserver kube-controller-manager kube-scheduler > /dev/null

# Declare versions
KUBE_APISERVER_VERSION=$(kube-apiserver --version | (read v1 v2; echo $v2))
KUBE_CONTROLLER_MANAGER_VERSION=$(kube-controller-manager --version | (read v1 v2; echo $v2))
KUBE_SCHEDULER_VERSION=$(kube-scheduler --version | (read v1 v2; echo $v2))
KUBECTL_VERSION=$(kubectl version -ojson | jq -r .clientVersion.gitVersion)

declare -A VERSION_ARRAY=( [kube-apiserver]=$KUBE_APISERVER_VERSION \
    [kube-controller-manager]=$KUBE_CONTROLLER_MANAGER_VERSION \
    [kube-scheduler]=$KUBE_SCHEDULER_VERSION \
    [kubectl]=$KUBECTL_VERSION )

$NEW_LINE

# Determine success
for service in "${!VERSION_ARRAY[@]}"; 
do
	if [[ ${VERSION_ARRAY[$service]} == $K8S_VERSION ]]
	then
            echo -e "$service version:" ${VERSION_ARRAY[$service]} "Successful! 👍🏽"
	else
        	echo -e "\n $service version:" ${VERSION_ARRAY[$service]} "Upgrade Unsuccessful 💩 "
	fi
done

$NEW_LINE
