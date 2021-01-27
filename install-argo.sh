#!/bin/sh

DNS_NAME=${1:-argocdx}
REGION=${2:-westeurope}

export KUBECONFIG=./config

#wget https://github.com/argoproj/argo-cd/releases/download/v1.7.7/argocd-linux-amd64 ; chmod +x argocd-linux-amd64 ; sudo mv argocd-linux-amd64 /usr/local/bin/argocd

echo "Deploying ArgoCD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Patching Argo for latest release and --insecure (TLS terminates at Traefik)"
kubectl patch -n argocd deployment/argocd-server --patch "$(cat patch.yaml)"
#or kubectl patch -n argocd deployment/argocd-server --patch "$(curl -L https://git.io/JTm7X)"

echo "Patching the IngressRoute with the correct name"
sed "s/DNS_NAME.REGION/${DNS_NAME}.${REGION}/g" ingressroute-argo-template.yaml > ingressroute-argo.yaml
kubectl apply -f ingressroute-argo.yaml
rm ingressroute-argo.yaml

#admin pass:

echo "Login at ${DNS_NAME}.${REGION}.cloudapp.azure.com with user admin"
echo "This is the inital ArgoCD password:"
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2| head -n 1

#kubectl -n argocd patch secret argocd-secret \
#  -p '{"stringData": {
#    "admin.password": "$2y$12$Iv3xVJsIWWSqV.YhAkUzW.V0fbWuuKdYAfUCjAy.RBVDTQ/IjAb1K",
#    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
#  }}'
#admin pass: 1$bFTA7RuC@tIb3j@

echo "Now you can login with the argo CLI like this:"
echo "argocd login --insecure --username admin --password 'pass' ${DNS_NAME}.${REGION}.cloudapp.azure.com"

#az aks get-credentials -g k8s -n playme -f playme.config
echo "You can then add any cluster with its kubeconfig file"
echo "argocd cluster add --kubeconfig kubeconfig cluster_name"