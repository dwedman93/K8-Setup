#!/bin/bash

export k8_nodetype='master'

echo $k8_nodetype

# Install dependencies
./setup_all.sh



sudo systemctl enable kubelet


sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock

sudo sysctl -p
# Init cluster
sudo kubeadm init \
  --pod-network-cidr=172.24.0.0/16 \
  --cri-socket unix:///run/containerd/containerd.sock


# Copy configuration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Install CNI Plugin (Calico) Others could be flannel, cilium, etc.
sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
