# Deployment Using Terraform
These are a set of terraform configuration files that will deploy a sample Formio application to AWS.

It is recommended you fork this library and customize it to meet your needs.  Each resource has been modularlized to allow for easy customization.

## Initializing Terraform
Initialize by calling `terraform init` in the root `aws` folder.  The vpc module uses a module provided by Hashicorp, it will also need to be initialied by changing to the the `modules/vpc` folder and executing `terraform init` in that folder as well.

Terraform keeps track of a environment state using a state file.  Currently it's created in the current folder.  Configure terraform to save in S3 or Terraform Cloud to ci/cd environments.

## AWS Access and Permissions needed to execute
Currently this script is pulling credentials from the `.aws/credentials` file and assumes an AWS role that has all of the permissions to create the AWS resources.  You can change this to get aws credentials from environment variables if running in a ci/cd environment
```tf
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
```
Script Variables
The following variables are defined to completely define the environment. Many have default values mainly just to aid in development and should be overridden in a production environment.

| Name | Description | Default Value |
| --- | --- | --- |
| terraform_create_role_arn | The ARN of the role that terraform will assume to create resources | "arn:aws:iam::164942174324:role/formio-terraform-create" |
| aws_region | AWS Region | "us-east-1" |
| availability_zones | Availability Zones | ["us-east-1a", "us-east-1b", "us-east-1c"] |
| vpc_cidr | VPC CIDR block | "10.0.0.0/16" |
| public_subnet_cidrs | public subnet cidr blocks | ["10.0.1.0/24", "10.0.2.0/24"] |
| private_subnet_cidrs | private subnet cidr blocks | ["10.0.101.0/24", "10.0.102.0/24"] |
| docdb_instance_class | docdb instance class | "db.r5.large" |
| docdb_master_password | docdb master password | "docdbpassword" |
| docdb_master_username | docdb master username | "docdbmaster" |
| docdb_database_name | docdb database name | "formio" |
| eb_instance_type | Elastic Beanstalk instance type | "t3.medium" |
| eb_instance_min_count | Elastic Beanstalk minimum instance count | 2 |
| eb_instance_max_count | Elastic Beanstalk maximum instance count | 4 |
| formio_database_name | formio database name | "formio" |
| formio_license_key | Your formio license key | "08XIuAFNjmquvnaKTotIhQTKzNbll" |
| formio_admin_email | Your formio admin email | "admin@example.com" |
| formio_admin_password | Your formio admin email | "CHANGEME" |
| formio_pdf_server | Your formio admin email | "http://pdf-server:4005" |
| formio_portal_enabled | Your formio admin email | 1 |
| formio_jwt_secret | Your formio jwt secret | "CHANGEME" |
| formio_server_port | Port that formio server listens on | 3000 |
