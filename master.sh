#!/bin/bash

export k8_nodetype='master'

echo $k8_nodetype

# Install dependencies
./setup.sh

# Init cluster
sudo kubeadm init


# Copy configuration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#sudo kubeadm join 192.168.178.51:6443 --token trg25f.7s8c3u2xz9uguzel   --discovery-token-ca-cert-hash sha256:519f38826fd3c12679736a206fd4bd52f5b148dd82ec981fb1dfb5a7733577c0