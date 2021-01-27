#!/bin/bash

#save as install-k3d.sh

curl https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu

curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

k3d cluster create k3d --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 2 --k3s-server-arg "--no-deploy=traefik"

su - ubuntu -c 'k3d kubeconfig merge k3d --switch-context -o /home/ubuntu/.kube/config'

wget "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
