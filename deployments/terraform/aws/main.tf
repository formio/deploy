terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.43.0"

    }
  }
  required_version = "~>v1.7.5"
}
provider "aws" {
  region = var.aws_region
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
module "s3" {
  source = "./modules/s3"
  pdf_s3_bucket = var.formio_pdf_s3_bucket
}

module "vpc" {
  source             = "./modules/vpc"
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnet_cidrs
  public_subnets     = var.public_subnet_cidrs
}

module "docdb" {
  source                 = "./modules/docdb"
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr               = var.vpc_cidr
  subnet_ids             = module.vpc.private_subnet_ids
  availability_zones     = var.availability_zones
  master_password        = var.docdb_master_password
  master_username        = var.docdb_master_username
  cluster_instance_count = local.docdb_cluster_instance_count
  ec2_instance_class     = var.docdb_instance_class
  database_name          = var.formio_database_name

}
module "elastic-beanstalk" {
  source               = "./modules/elastic-beanstalk"
  deployment_s3_bucket = module.s3.formio_resources_bucket
  app_version          = var.app_version
  private_security_group_id = module.docdb.formio_private_securty_group_id
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnet_ids
  private_subnets      = module.vpc.private_subnet_ids
  instance_type        = var.eb_instance_type
  asg_min_count        = var.eb_instance_min_count
  asg_max_count        = var.eb_instance_max_count
  db_connection_string = module.docdb.connection_string
  jwt_secret           = var.formio_jwt_secret
  admin_email          = var.formio_admin_email
  admin_password       = var.formio_admin_password
  pdf_server           = var.formio_pdf_server
  formio_license_key   = var.formio_license_key
  pdf_s3_bucket        = var.formio_pdf_s3_bucket
  s3_region            = var.aws_region
# FORMIO_S3_SECRET=Ln6aKdQZ8ey3fPKLMmbHoSHtahN5I4pIjaxPHmw9
}

output "root_path" {
  value = module.elastic-beanstalk.archive_file_path

}

# output "deployment_source" {
#   value = module.elastic-beanstalk.eb_deployment_source
# }
