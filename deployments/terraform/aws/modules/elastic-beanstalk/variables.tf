variable "app_version" {
  type        = string
  description = "unique version label for the application deployment"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"

}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "deployment_s3_bucket" {
  type        = string
  description = "S3 bucket where deployment artifacts are stored"
}
# variable "deployment_s3_key" {
#   type        = string
#   description = "S3 key where deployment artifacts are stored"

# }
variable "private_security_group_id" {
  type        = string
  description = "security group that connects to vpc private subnets"
  
}
variable "private_subnets" {
  type        = list(string)
  description = "list of private subnet from"
}
variable "public_subnets" {
  type        = list(string)
  description = "list of private subnet from"
}
variable "instance_type" {
  type        = string
  description = "instance type"

}
variable "asg_min_count" {
  type        = number
  description = "minimum number of instances in the auto scaling group"
}
variable "asg_max_count" {
  type        = number
  description = "minimum number of instances in the auto scaling group"
}
variable "db_connection_string" {
  type        = string
  description = "connection string to the database"

}
variable "jwt_secret" {
  type        = string
  description = "jwt token secret"
}
variable "admin_email" {
  type        = string
  description = "admin email"
}
variable "admin_password" {
  type        = string
  description = "admin password"
}
variable "pdf_server" {
  type        = string
  description = "pdf server"
  default     = "http://pdf-server:4005"
}
variable "portal_enabled" {
  type        = number
  description = "portal enabled"
  default     = 1
}
variable "port" {
  type        = number
  description = "port"
  default     = 3000
}
variable "formio_license_key" {
  type        = string
  description = "formio license key"
}
variable "pdf_s3_bucket" {
  type        = string
  description = "formio license key"
}

variable "s3_region" {
  type        = string
  description = "formio license key"
}

locals {
  deployment_bundle      = "application-bundle-${var.app_version}.zip"
  deployment_bundle_path = "${path.root}/${local.deployment_bundle}"
}
