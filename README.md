# Disclaimer -- Use at your own risk
These deployment scripts are meant as examples of how to deploy the Formio servers into your environment. They should be carefully reviewed and modified accordingly to ensure they meet any specific deployment and/or security requirements

# Deployment strategies for Form.io Enterprise platform
This repo contains all of the deployment strategies for the Form.io Enterprise Platform. These deployments contain the following strategies.

 - Docker Compose
 - Terraform (coming soon)
 - Kubernetes

## Requirements
To run this tool, you'll need NodeJS v16 or higher.

## Installation
To install this library, you can type the following in your terminal.

```
npm install -g @formio/deploy
```

## Requirements

You'll need NodeJS >= 18.

## Usage
You can now use this CLI to create deployment packages.

```
formio-deploy package --license=YOURLICENSE
```

This will then create a series of deployments within a "deployments" folder that you can use to deploy Form.io Enterprise within your environment.

### Commands
The following commands are supported.

#### package
Create new deployment packages provided certain arguments.

```sh
➜  ~ formio-deploy package --help
Usage: formio-deploy package|p [options] [path]

Create a new deployment package.

Options:
  --license [LICENSE_KEY]  Your deployment license.
  --server [server]        The Form.io Enterprise Server Docker repo
  --version [version]      The Form.io Enterprise Server version.
  --pdf-version [version]  The Form.io PDF Server version.
  --sub-version [version]  The Form.io Submission Server version.
  --db-secret [secret]     The Database Secret.
  --jwt-secret [secret]    The JWT Token Secret
  --admin-email [email]    The default root admin email address
  --admin-pass [password]  The default root admin password
  --ssl-cert [cert]        File path to the SSL Certificate for the deployment to enable SSL.
  --ssl-key [key]          File path to the SSL Certificate Key for the deployment to enable SSL.
  -h, --help               display help for command
```

##### Example
The following will create a new multi-container deployment package for AWS, with version 7.3.0 Server Version and 3.3.1 PDF Server Version.

```
formio-deploy package compose/aws/multicontainer.zip --license=YOURLICENSE --version=7.3.0 --pdf-version=3.3.1
```

Once this is done, it will generate a new ZIP file within the deployments folder for ```compose/aws/multicontainer.zip``` as well as place the deployment in the ```deployments/current``` folder.  You can now use the ZIP file to deploy to AWS Elastic Beanstalk.

##### Local Example
You can also use this command to create a local deployment on your local machine by first typing the following.

```
formio-deploy package compose/multicontainer.zip --license=YOURLICENSE --version=7.3.0 --pdf-version=3.3.1
```

and then type the following to run.

```
docker-compose -f ~/deployments/current/docker-compose.yml up
```

### [Kubernetes Deployment Guide](https://help.form.io/deployments/deployment-guide/kubernetes)

#### CLI Variables
PROVIDER = aws | azure  
API_NAMESPACE = formio-dev | formio-staging | formio-prod  
PDF_NAMESPACE = formio-pdf  
LICENSE_KEY = your_formio_license_key

#### API Server (Portal Enabled)

```sh
PROVIDER=azure
API_NAMESPACE=formio-dev
PDF_NAMESPACE=formio-pdf
LICENSE_KEY=your_license_key_here

echo ""
echo "Provider: $PROVIDER"
echo "Namespace API: $API_NAMESPACE"
echo "Namespace PDF: $PDF_NAMESPACE"
echo "License Key: $LICENSE_KEY"
echo ""

# Create helm deployment zip
formio-deploy package helm/$PROVIDER/api-server.zip \
--license=$LICENSE_KEY \
--version=8.4.1 \
--admin-email='admin@example.com' \
--admin-pass='CHANGEME' \
--db-secret='CHANGEME' \
--jwt-secret='CHANGEME' \
--pdf-server-url="http://pdf-server.$PDF_NAMESPACE.svc.cluster.local:4005" \
--base-url="$API_NAMESPACE.localdev.me" # dev.<your-domain>.com | authoring.<your-domain>.com

# Unzip helm deployment
cd ./deployments/helm/$PROVIDER
unzip -d . api-server.zip && mv helm api-server

# Change to directory
cd api-server

# View current .env (This should be edited before continuing)
cat .env

# Deploy
bash scripts/upgrade.sh --namespace $API_NAMESPACE --path ./deployment
```

#### Remote API Server

```sh
PROVIDER=azure
API_NAMESPACE=formio-staging
PDF_NAMESPACE=formio-pdf
LICENSE_KEY=your_license_key_here

echo ""
echo "Provider: $PROVIDER"
echo "Namespace API: $API_NAMESPACE"
echo "Namespace PDF: $PDF_NAMESPACE"
echo "License Key: $LICENSE_KEY"

# Create helm deployment zip
formio-deploy package helm/$PROVIDER/remote-server.zip \
--no-portal \
--license=$LICENSE_KEY \
--version=8.4.1 \
--admin-email='admin@example.com' \
--admin-pass='CHANGEME' \
--db-secret='CHANGEME' \
--jwt-secret='CHANGEME' \
--portal-secret='CHANGEME' \
--pdf-server-url="http://pdf-server.$PDF_NAMESPACE.svc.cluster.local:4005" \
--base-url="$API_NAMESPACE.localdev.me" # staging.<your-domain>.com | uat.<your-domain>.com | live.<your-domain>.com

# Unzip helm deployment
cd ./deployments/helm/$PROVIDER
unzip -d . remote-server.zip && mv helm remote-server

# Change to directory
cd remote-server

# View current .env (This should be edited before continuing)
cat .env

# Deploy
bash scripts/upgrade.sh --namespace $API_NAMESPACE --path ./deployment
```

#### PDF Server

```sh
PROVIDER=azure
PDF_NAMESPACE=formio-pdf
LICENSE_KEY=your_license_key_here

echo ""
echo "Provider: $PROVIDER"
echo "Namespace PDF: $PDF_NAMESPACE"
echo "License Key: $LICENSE_KEY"

# Create helm deployment zip
formio-deploy package helm/$PROVIDER/pdf-server.zip \
--license=$LICENSE_KEY \
--pdf-version=5.4.2

# Unzip helm deployment
cd ./deployments/helm/$PROVIDER
unzip -d . pdf-server.zip && mv helm pdf-server

# Change to directory
cd pdf-server

# View current .env (This should be edited before continuing)
cat .env

# Deploy
bash scripts/upgrade.sh --namespace $PDF_NAMESPACE --path ./deployment
```

##### Multicontainer

```sh
PROVIDER=azure
API_NAMESPACE=formio-prod
LICENSE_KEY=your_license_key_here

echo ""
echo "Provider: $PROVIDER"
echo "Namespace API: $API_NAMESPACE"
echo "License Key: $LICENSE_KEY"

# Create helm deployment zip
formio-deploy package helm/$PROVIDER/multicontainer.zip \
--license=$LICENSE_KEY \
--version=8.4.1 \
--pdf-version=5.4.2 \
--admin-email='admin@example.com' \
--admin-pass='CHANGEME' \
--db-secret='CHANGEME' \
--jwt-secret='CHANGEME' \
--base-url="$API_NAMESPACE.localdev.me"

# Unzip helm deployment
cd $(pwd)/deployments/helm/$PROVIDER
unzip -d . multicontainer.zip && mv helm multicontainer

# Change to directory
cd multicontainer

# View current .env (This should be edited before continuing)
cat .env

# Deploy
bash scripts/upgrade.sh --namespace  $API_NAMESPACE --path ./deployment
```
