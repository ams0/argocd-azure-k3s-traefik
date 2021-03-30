#!/bin/bash

RG=${1:-k3s}
DNS_NAME=${2:-argocdx}
REGION=westeurope
VM_SIZE=Standard_B8ms

#create the VM and open ports
echo "Creating resource group"
az group create -n $RG -l $REGION

echo "Creating VM.."
az vm create -g $RG --image UbuntuLTS --size ${VM_SIZE} --admin-username ubuntu --ssh-key-values ~/.ssh/id_rsa.pub -n $RG --public-ip-address-dns-name $DNS_NAME --custom-data install-k3d.sh -l $REGION
echo "..done!"

echo "Setting network rules.."
az network nsg rule create -g $RG --nsg-name ${RG}NSG --priority 1001 --access Allow --protocol Tcp --destination-port-ranges 443 -n https
az network nsg rule create -g $RG --nsg-name ${RG}NSG --priority 1002 --access Allow --protocol Tcp --destination-port-ranges 80 -n http
az network nsg rule create -g $RG --nsg-name ${RG}NSG --priority 1003 --access Allow --protocol Tcp --destination-port-ranges 6443 -n api
echo "..done!"

#wait for k3s to be deployed
echo "Sleeping 2 minutes to let k3s to be fully deployed.."
sleep 120
echo "..done!"

echo "Getting the Kubeconfig file from the k3s VM"
#retrieve the Kubeconfig file
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${DNS_NAME}.${REGION}.cloudapp.azure.com:/home/ubuntu/.kube/config ./config
sed -i "s/0.0.0.0/${DNS_NAME}.${REGION}.cloudapp.azure.com/g" config
export KUBECONFIG=./config
echo "..done!"

echo "Let's see if it works"
kubectl get pod -A
