#!/bin/bash

# Initialize default values
NAMESPACE=""
PATH_TO_CHART=""

# Function to display usage
usage() {
    echo "Usage: $0 [-n|--namespace NAMESPACE] [-p|--path PATH_TO_CHART]"
    echo "  If arguments are not provided, you will be prompted to enter them."
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--namespace) NAMESPACE="$2"; shift ;;
        -p|--path) PATH_TO_CHART="$2"; shift ;;
        -h|--help) usage; exit 0 ;;
        *)
            if [ -z "$NAMESPACE" ]; then
                NAMESPACE="$1"
            elif [ -z "$PATH_TO_CHART" ]; then
                PATH_TO_CHART="$1"
            else
                echo "Unknown or excess parameter passed: $1"
                usage
                exit 1
            fi
            ;;
    esac
    shift
done

# Check if NAMESPACE is empty and ask for user input if necessary
if [ -z "$NAMESPACE" ]; then
    read -p 'Enter NAMESPACE: ' NAMESPACE
fi

# Check if PATH_TO_CHART is empty and ask for user input if necessary
if [ -z "$PATH_TO_CHART" ]; then
    read -p 'Enter PATH_TO_CHART: ' PATH_TO_CHART
fi

echo ""
### Set Environment Variables
set -a # automatically export all variables
source .env
set +a
# cat .env
echo ""
echo ""
helm -n $NAMESPACE upgrade -i --debug --wait --atomic \
--set appEnv=$APP_ENV \
--set image.repository=$API_IMAGE \
--set pdf.repository=$PDF_IMAGE \
--set mongo=$MONGO \
--set licenseKey=$LICENSE_KEY \
--set port=$PORT \
--set debug=$DEBUG \
--set baseUrl=$BASE_URL \
--set portalEnabled=$PORTAL_ENABLED \
--set portalSecret=$PORTAL_SECRET \
--set adminEmail=$ADMIN_EMAIL \
--set adminPass=$ADMIN_PASS \
--set dbSecret=$DB_SECRET \
--set jwtSecret=$JWT_SECRET \
--set pdfServer=$PDF_SERVER \
--set formioAzureContainer=$FORMIO_AZURE_CONTAINER \
--set formioAzureConnectionString=$FORMIO_AZURE_CONNECTION_STRING \
formio $PATH_TO_CHART
echo ""
echo ""
kubectl -n $NAMESPACE get all
