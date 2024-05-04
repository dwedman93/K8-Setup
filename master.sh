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

#sudo kubeadm join 192.168.178.51:6443 --token trg25f.7s8c3u2xz9uguzel   --discovery-token-ca-cert-hash sha256:519f38826fd3c12679736a206fd4bd52f5b148dd82ec981fb1dfb5a7733577c0