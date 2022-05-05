#!/bin/bash



<<DESCRIPTION
Bash script for installation & configuration of k8s on 
Debian 11 Bullseye with Docker and some base tools ...
DESCRIPTION



##################################################
### variables

BRED='\033[1;31m'
BWHITE='\033[1;37m'
NC='\033[0m'

##################################################
### general changes

# fix Debian locales
if ! grep -q "export LC_ALL=C" ~/.bashrc; then
    echo -e "\n# quick fix locale issue \nexport LC_ALL=C" >> ~/.bashrc
    . ~/.bashrc
    echo -e "\n.bashrc was modified -> Debian locales error fixed \n"
fi

# system update
sudo apt update && \
sudo apt upgrade

# base tools installation
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    screenfetch \
    netcat \
    netstat-nat \
    bash-completion

##################################################
### Docker installation

# add Docer repo key
curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# add Docker repo
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update repos + install Docker
sudo apt update && \
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    containerd.io

# fix access to docker.sock
sudo groupadd docker
sudo usermod -aG docker ${USER}

##################################################
### k8s

# tools for using k8s repo
sudo apt install \
    apt-transport-https

# add k8s repo key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key add

# add k8s repo
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# update repos + install k8s components
sudo apt update && \
sudo apt install -y \
    kubelet \
    kubeadm \
    kubectl

# enable autocompletion for k8s components
if ! grep -q "source <(kubectl completion bash)" ~/.bashrc; then
    echo -e "\n# autocompletion for k8s \nsource <(kubectl completion bash)" >> ~/.bashrc
    . ~/.bashrc
    echo -e "\n.bashrc was modified -> k8s components autocompletion \n"
fi

# additional configuring for k8s
sudo swapoff -a

##################################################
### post installation changes

echo -e "\n\nNow run ${BWHITE}\$${BRED} sudo reboot now${NC} to apply all changes ...\n\n"
