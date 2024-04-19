# Deployment Using Terraform
These are a set of terraform configuration files that will deploy a sample Formio application to AWS.

It is recommended you fork this library and customize it to meet your needs.  Each resource has been modularlized to allow for easy customization.

## Initializing Terraform
Initialize by calling `terraform init` in the root `aws` folder.  The vpc module uses a module provided by Hashicorp, it will also need to be initialied by changing to the the `modules/vpc` folder and executing `terraform init` in that folder as well.

Terraform keeps track of a environment state using a state file.  Currently it's created in the current folder.  Configure terraform to save in S3 or Terraform Cloud to ci/cd environments.

## AWS Access and Permissions needed to execute
Currently this script is pulling credentials from the `.aws/credentials` file and assumes an AWS role that has all of the permissions to create the AWS resources.  You can change this to get aws credentials from environment variables if running in a ci/cd environment

```terraform
provider "aws" {
  region                   = var.aws_region
  # pulling credentials from the default profile in ~/.aws/credentials
  # change to
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"

  # aws user assumes a role instead of having all permissions
  # explicitly defined on the user account
  assume_role {
    role_arn = var.terraform_create_role_arn

  }
}
Set the default value for `terraform_create_role_arn` with a role ARN with the following permissions.
```
### Creation Role Permissions
The role that the user running this script Needs access to create a lot of things in AWS. Putting this in a role that is temporarily assumed by the executing user prevents having to permanantly assign those permissions.  These are the policies that were attached to the role, you might be able to get these finer grained, but it worked during development of the terraform scripts.
* AdministratorAccess-AWSElasticBeanstalk
* AmazonEC2ContainerRegistryFullAccess
* AmazonRDSFullAccess
* AmazonS3FullAccess
* AmazonVPCFullAccess
* *IAMFullAccess

## Created Resources
This script will generate the following resources on AWS:
* S3 Buckets are created for Elastic Beanstalk deployments and PDF Server storage
* VPC in the defined region and availablity zones with a public and private subnet and routing tables for them.  It uses a Hashicorp provided module to generate all of additional VPC resources necessary
* Amazon Document DB Cluster.  Instance are in the region and assigned to the private subnet and security groups.  Security groups have Ingress ports open
* Elastic Beanstalk Deployment and necessary roles and policies to run. Attached to the VPC public subnet and Elastic Load Balancer

## Modules
| Name | Source | Version |
|------|--------|---------|
| [docdb](#module\_docdb) | ./modules/docdb | n/a |
| [elastic-beanstalk](#module\_elastic-beanstalk) | ./modules/elastic-beanstalk | n/a |
| [s3](#module\_s3) | ./modules/s3 | n/a |
| [vpc](#module\_vpc) | ./modules/vpc | n/a |
## Script Variables
The following variables are defined to completely define the environment. Many have default values mainly just to aid in development and should be overridden in a production environment.
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|  [app\_version](#input\_app\_version) | unique string to identify the version being deployed | `string` | n/a | yes |
|  [availability\_zones](#input\_availability\_zones) | Availability Zones | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b"<br>]</pre> | no |
|  [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"us-east-1"` | no |
|  [docdb\_database\_name](#input\_docdb\_database\_name) | docdb database name | `string` | `"formio"` | no |
|  [docdb\_instance\_class](#input\_docdb\_instance\_class) | docdb instance class | `string` | `"db.r5.large"` | no |
|  [docdb\_master\_password](#input\_docdb\_master\_password) | docdb master password | `string` | `"docdbpassword"` | no |
|  [docdb\_master\_username](#input\_docdb\_master\_username) | docdb master username | `string` | `"docdbmaster"` | no |
|  [eb\_instance\_max\_count](#input\_eb\_instance\_max\_count) | Elastic Beanstalk maximum instance count | `number` | `4` | no |
|  [eb\_instance\_min\_count](#input\_eb\_instance\_min\_count) | Elastic Beanstalk minimum instance count | `number` | `1` | no |
|  [eb\_instance\_type](#input\_eb\_instance\_type) | Elastic Beanstalk instance type | `string` | `"t3.medium"` | no |
|  [formio\_admin\_email](#input\_formio\_admin\_email) | Your formio admin email | `string` | `"admin@example.com"` | no |
|  [formio\_admin\_password](#input\_formio\_admin\_password) | Your formio admin email | `string` | `"CHANGEME"` | no |
|  [formio\_database\_name](#input\_formio\_database\_name) | formio database name | `string` | `"formio"` | no |
|  [formio\_jwt\_secret](#input\_formio\_jwt\_secret) | Your formio jwt secret | `string` | `"CHANGEME"` | no |
|  [formio\_license\_key](#input\_formio\_license\_key) | Your formio license key | `string` | `"08XIuAFNjmquvnaKTotIhQTKzNbll"` | no |
|  [formio\_pdf\_s3\_bucket](#input\_formio\_pdf\_s3\_bucket) | S3 bucket for formio resources | `string` | `"tf-formio-pdf"` | no |
|  [formio\_pdf\_server](#input\_formio\_pdf\_server) | Your formio admin email | `string` | `"http://pdf-server:4005"` | no |
|  [formio\_portal\_enabled](#input\_formio\_portal\_enabled) | Your formio admin email | `number` | `1` | no |
|  [formio\_server\_port](#input\_formio\_server\_port) | Port that formio server listens on | `number` | `3000` | no |
|  [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | private subnet cidr blocks | `list(string)` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24"<br>]</pre> | no |
|  [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | public subnet cidr blocks | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24"<br>]</pre> | no |
|  [terraform\_create\_role\_arn](#input\_terraform\_create\_role\_arn) | The ARN of the role that terraform will assume to create resources | `string` | `"arn:aws:iam::164942174324:role/formio-terraform-create"` | no |
|  [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR block | `string` | `"10.0.0.0/16"` | no |