#!/bin/bash

# Configuration


# Using own hostname for every worker.
export k8_hostname=$(hostname)


# End Configuration



if [[ $k8_nodetype=='master' ]]; then
echo 'Doing konfiguraion for master node'
elif [[ $k8_nodetype=='worker' ]]; then
echo 'This is worker. Doing Konfiguration for worker node'
fi


# Turn swap off
sudo swapoff -a

# comment out swap in /etc/fstab
sudo sed -e '/swap.img/ s/^#*/#/' -i /etc/fstab

# Install docker
sudo apt install docker.io -y


# Install curl
sudo apt install apt-transport-https curl -y

# Add repositoy key for downloading and installing kubernetes
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

# Install kubernetes apps

sudo apt-get install kubeadm kubelet kubectl kubernetes-cni -y


if [[ $k8_nodetype=='master' ]]; then
echo 'Init Cluster'
sudo kubeadm init
fi

