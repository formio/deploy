# Deployment strategies for Form.io Enterprise platform
This repo contains all of the deployment strategies for the Form.io Enterprise Platform. These deployments contain the following strategies.

 - Docker Compose
 - Terraform (coming soon)
 - Kubernetes (coming soon)

## Installation
To install this library, you can type the following in your terminal.

```
npm install -g @formio/deploy
```

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
