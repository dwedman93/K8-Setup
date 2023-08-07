#!/bin/bash

# Configuration


# Using own hostname for every worker.
export k8_hostname=$(hostname)


# End Configuration



if [[ "${k8_nodetype^}" = "master" ]]; then
    echo 'Doing konfiguraion for master node'
elif [[ "${k8_nodetype^}" = "worker" ]]; then
    echo 'This is worker. Doing Konfiguration for worker node'
fi


# Turn swap off
sudo swapoff -a

# comment out swap in /etc/fstab
sudo sed -e '/swap.img/ s/^#*/#/' -i /etc/fstab

# Install docker
sudo apt install docker.io -y


cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo apt-get update
sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo vi /etc/containerd/config.toml
#find the [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] section and change systemdcgroup to true
#SystemdCgroup = true

sudo systemctl restart containerd
sudo systemctl enable containerd
sudo containerd config dump

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward


sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add repositoy key for downloading and installing kubernetes
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpgecho "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# Install kubernetes apps

sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni


if [[ "${k8_nodetype^}" = "master" ]]; then
    echo 'Init Cluster'
#    sudo kubeadm init
fi