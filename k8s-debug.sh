#!/bin/bash

### Set Environment Variables
# set -a # automatically export all variables
# source .env # Env Filename
# set +a

PROVIDER=aws
API_NAMESPACE=formio-dev
PDF_NAMESPACE=formio-pdf
LICENSE_KEY=

echo ""
echo "Provider: $PROVIDER"
echo "Namespace API: $API_NAMESPACE"
echo "Namespace PDF: $PDF_NAMESPACE"
echo "License Key: $LICENSE_KEY"
echo ""

#############################################################
### API Server 
#############################################################
# formio-deploy package helm/$PROVIDER/api-server.zip \
# --license=$LICENSE_KEY \
# --version=8.4.1 \
# --admin-email='admin@example.com' \
# --admin-pass='CHANGEME' \
# --db-secret='CHANGEME' \
# --jwt-secret='CHANGEME' \
# --pdf-server-url="http://pdf-server.$PDF_NAMESPACE.svc.cluster.local:4005" \
# --base-url="$API_NAMESPACE.localdev.me"

#############################################################
### Remote API Server 
#############################################################
# formio-deploy package helm/$PROVIDER/remote-server.zip \
# --no-portal \
# --license=$LICENSE_KEY \
# --version=8.4.1 \
# --admin-email='admin@example.com' \
# --admin-pass='CHANGEME' \
# --db-secret='CHANGEME' \
# --jwt-secret='CHANGEME' \
# --portal-secret='CHANGEME' \
# --pdf-server-url="http://pdf-server.$PDF_NAMESPACE.svc.cluster.local:4005" \
# --base-url="$API_NAMESPACE.localdev.me"

#############################################################
### PDF Server
### ---------------------------------------------------------
### This isolated in its own namespace might be
### more benenficial that adding to the same namespace as
### an API server. Would prevent accidental deployments but 
### could be easier to scale and upgrade in its own namespace
#############################################################
formio-deploy package helm/$PROVIDER/pdf-server.zip \
--pdf-version=5.4.2 \
--license=$LICENSE_KEY

#############################################################
### Multicontainer Server
### ---------------------------------------------------------
### Would use this configuration for production envs
### that will be connnected to a lower environment portal
### can couple the pdf-server with api-server but see more
### benefit of standalone api-server & pdf-server in their
### own namespaces.
#############################################################
# formio-deploy package helm/$PROVIDER/multicontainer.zip \
# --license=$LICENSE_KEY \
# --version=8.4.1 \
# --pdf-version=5.4.2 \
# --pdf-server-url="http://pdf-server:4005" \
# --admin-email='admin@example.com' \
# --admin-pass='CHANGEME' \
# --db-secret='CHANGEME' \
# --jwt-secret='CHANGEME' \
# --base-url="$API_NAMESPACE.localdev.me"