#!/bin/bash

# Configuration


# Using own hostname for every worker.
export k8_hostname=$(hostname)


# End Configuration


# Turn swap off
sudo swapoff -a

# comment out swap in /etc/fstab
sudo sed -e '/swap.img/ s/^#*/#/' -i /etc/fstab


if [[ $k8_nodetype=='master' ]]; then
echo 'This is master'
elif [[ $k8_nodetype=='worker' ]]; then
echo 'This is worker'
fi

