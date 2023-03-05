#!/bin/bash

# Declare variables
TARGET_VERSION="v1.24.0"
GOOGLE_URL=https://storage.googleapis.com
DOWNLOAD_URL=${GOOGLE_URL}/kubernetes-release/release/${TARGET_VERSION}/bin/linux/amd64
CONTROLLER_SERVICES=(kube-apiserver kube-controller-manager kube-scheduler kubectl)
NEW_LINE=$(echo -e "\n")
UPGRADE_LOG=/tmp/controller-upgrade-error.log

# Truncate old log
truncate -s 0 $UPGRADE_LOG

# Download binaries
for service in "${CONTROLLER_SERVICES[@]}";
do 
    wget -q --show-progress --https-only --timestamping ${DOWNLOAD_URL}/$service
done

# Install binaries
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

$NEW_LINE

# Start controller services
echo "========== Restarting Controller Services =========="
RESTART_SERVICES=$(sudo systemctl daemon-reload && \
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler && \
sudo systemctl restart kube-apiserver kube-controller-manager kube-scheduler && \
sudo systemctl status --full kube-apiserver kube-controller-manager kube-scheduler &> $UPGRADE_LOG)

if [[ $RESTART_SERVICES ]]
then
    echo -e "All services restarted successfully!\n"
else
    echo -e "Service restarts unsuccessful. Please check $UPGRADE_LOG for more information\n"
fi

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
	if [[ ${VERSION_ARRAY[$service]} == $TARGET_VERSION ]]
	then
            echo -e "$service version:" ${VERSION_ARRAY[$service]} "Successful! 👍🏽"
	else
        	echo -e "\n $service version:" ${VERSION_ARRAY[$service]} "Upgrade Unsuccessful 💩 "
	fi
done

$NEW_LINE
