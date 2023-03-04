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

# Declare versions
KUBE_APISERVER_VERSION=$(kube-apiserver --version | (read v1 v2; echo $v2))
KUBE_CONTROLLER_MANAGER_VERSION=$(kube-controller-manager --version | (read v1 v2; echo $v2))
KUBE_SCHEDULER_VERSION=$(kube-scheduler --version | (read v1 v2; echo $v2))
KUBECTL_VERSION=$(kubectl version -ojson | jq -r .clientVersion.gitVersion)
VERSION_ARRAY=($KUBE_APISERVER_VERSION $KUBE_CONTROLLER_MANAGER_VERSION $KUBE_SCHEDULER_VERSION $KUBECTL_VERSION)

# Verify versions
echo -e "\n"
for service in kube-apiserver kube-controller-manager kube-scheduler;
do
	echo "$service version:" $($service --version)
done

echo "kubectl version:" $(kubectl version -ojson | jq -r .clientVersion.gitVersion)


# Determine success
for service_version in "${VERSION_ARRAY[@]}" 
do
	if [[ $service_version == $K8S_VERSION ]]
	then
		for service in kube-apiserver kube-controller-manager kube-scheduler;
		do
			echo -e "$service version:" $($service --version) "Successful! 👍🏽  \n"
 		done
	else
        	echo -e "\n $service_version Upgrade Unsuccessful 💩 \n"
	fi
done
