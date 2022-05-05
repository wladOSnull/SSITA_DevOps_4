#!/bin/bash



<<DESCRIPTION
Bash script for deploying & configuration of k8s on 
Debian 11 Bullseye as master node
DESCRIPTION


##################################################
### base k8s configs

# first initialization
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# get joining string
CONNECTOR=`sudo kubeadm token create --print-join-command`

# relocate config file for main system user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

##################################################
### apply pods networking scheme

# apply 'flannel' config
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo -e "\n\nThen you can join any number of worker nodes by running the following on each as root:\n ${CONNECTOR}\n\n"