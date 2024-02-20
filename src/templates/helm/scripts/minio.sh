#!/bin/bash

echo ""
read -p 'Enter NAMESPACE: ' NAMESPACE
echo ""

helm install --namespace $NAMESPACE \
--set rootUser=rootuser,rootPassword=rootpass123 \
--set buckets[0].name=formio,buckets[0].policy=none,buckets[0].purge=false \
--generate-name minio/minio

#################################
## FIND POD_NAME
#################################
# export POD_NAME=$(kubectl get pods --namespace formio -l "release=minio-1664384246" -o jsonpath="{.items[0].metadata.name}")

#################################
## Expose Minio Interface
#################################
# kubectl port-forward $POD_NAME 9000 --namespace formio

#################################
## Get ACCESS_KEY and SECRET_KEY -> Add to .env
#################################
# ACCESS_KEY=$(kubectl -n $NAMESPACE get secret minio-1664306856 -o jsonpath="{.data.accesskey}" | base64 --decode)
# echo $ACCESS_KEY
# SECRET_KEY=$(kubectl -n $NAMESPACE get secret minio-1664306856 -o jsonpath="{.data.secretkey}" | base64 --decode)
# echo $SECRET_KEY
