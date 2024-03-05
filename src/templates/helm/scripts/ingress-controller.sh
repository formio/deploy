#!/bin/bash

#####################################################################################
## Ingress Controller Local Docker Desktop
## ----------------------------------------------------------------------------------
## https://kubernetes.github.io/ingress-nginx/deploy/#quick-start
#####################################################################################
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace


#####################################################################################
## AKS Ingress Controller
## -----------------------------------------------------------------------------
## https://stacksimplify.com/azure-aks/azure-kubernetes-service-ingress-basics/
#####################################################################################
# helm install ingress-nginx ingress-nginx/ingress-nginx \
#     --version 4.1.3 \
#     --namespace ingress-basic \
#     --create-namespace \
#     --set controller.replicaCount=2 \
#     --set controller.nodeSelector."kubernetes\.io/os"=linux \
#     --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
#     --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
#     --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
#     --set controller.service.externalTrafficPolicy=Local


#####################################################################################
## EKS Ingress Controller (Needs Testing)
## -----------------------------------------------------------------------------
## https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
#####################################################################################
# helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
# 	--set clusterName=<k8s-cluster-name> \
# 	--set serviceAccount.create=false \
# 	--set serviceAccount.name=aws-load-balancer-controller
