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



sudo apt -y install curl apt-transport-https
curl  -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# comment out swap in /etc/fstab
sudo sed -e '/swap.img/ s/^#*/#/' -i /etc/fstab

# Turn swap off
sudo swapoff -a
sudo mount -a
free -h


# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

# Configure persistent loading of modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure sysctl params are set
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs
sudo sysctl --system

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start service
sudo su -
mkdir -p /etc/containerd
sudo containerd config default>/etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
#systemctl status  containerd
exit

sudo sed -i -e '/systemd_cgroup =/ s/= .*/= true/' /etc/containerd/config.toml

if [[ "${k8_nodetype^}" = "master" ]]; then
    echo 'Init Cluster'
#    sudo kubeadm init
fi