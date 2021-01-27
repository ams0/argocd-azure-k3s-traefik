#!/bin/bash

#Until Traefik 2.0 makes into k3s, we need to install it separately with helm #https://github.com/rancher/k3s/issues/1141
#as Traefik 2.0 
#also, https://github.com/traefik/traefik/issues/7414 hence /data/acme.json

echo "Adding and updating Traefik helm repo, if you don't have it already, won't hurt"
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

export KUBECONFIG=./config
helm upgrade --install --create-namespace \
-n ingress --wait \
--set rbac.enabled=true \
--set metrics.prometheus.enabled=true \
--set="additionalArguments={--certificatesresolvers.default.acme.httpChallenge.entryPoint=web,--certificatesresolvers.default.acme.storage=/data/acme.json,--certificatesresolvers.default.acme.email=alessandro.vozza@microsoft.com,--certificatesresolvers.default.acme.httpChallenge=true,--providers.kubernetesingress.ingressclass=traefik,--log.level=DEBUG}" \
traefik traefik/traefik


#kubectl port-forward -n ingress $(kubectl get pods -n ingress --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000 &
#open http://127.0.0.1:9000/dashboard/ 