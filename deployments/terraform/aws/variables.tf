variable "app_version" {
  type        = string
  description = "unique string to identify the version being deployed"
}

variable "terraform_create_role_arn" {
  type        = string
  description = "The ARN of the role that terraform will assume to create resources"
  default     = "arn:aws:iam::164942174324:role/formio-terraform-create"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "public subnet cidr blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnet cidr blocks"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "docdb_instance_class" {
  type        = string
  description = "docdb instance class"
  default     = "db.r5.large"
}

variable "docdb_master_password" {
  type        = string
  description = "docdb master password"
  default     = "docdbpassword"
}
variable "docdb_master_username" {
  type        = string
  description = "docdb master username"
  default     = "docdbmaster"
}
variable "docdb_database_name" {
  type        = string
  description = "docdb database name"
  default     = "formio"

}
variable "eb_instance_type" {
  type        = string
  description = "Elastic Beanstalk instance type"
  default     = "t3.medium"
}
variable "eb_instance_min_count" {
  type        = number
  description = "Elastic Beanstalk minimum instance count"
  default     = 1

}
variable "eb_instance_max_count" {
  type        = number
  description = "Elastic Beanstalk maximum instance count"
  default     = 4

}

variable "formio_database_name" {
  type        = string
  description = "formio database name"
  default     = "formio"

}
variable "formio_license_key" {
  type        = string
  description = "Your formio license key"
  default     = "08XIuAFNjmquvnaKTotIhQTKzNbll"

}

variable "formio_admin_email" {
  type        = string
  description = "Your formio admin email"
  default     = "admin@example.com"

}
variable "formio_admin_password" {
  type        = string
  description = "Your formio admin email"
  default     = "CHANGEME"

}
variable "formio_pdf_server" {
  type        = string
  description = "Your formio admin email"
  default     = "http://pdf-server:4005"

}
variable "formio_portal_enabled" {
  type        = number
  description = "Your formio admin email"
  default     = 1

}
variable "formio_jwt_secret" {
  type        = string
  description = "Your formio jwt secret"
  default     = "CHANGEME"

}
variable "formio_server_port" {
  type        = number
  description = "Port that formio server listens on"
  default     = 3000
}

variable "formio_pdf_s3_bucket" {
  type        = string
  description = "S3 bucket for formio resources"
  default     = "tf-formio-pdf"
}


locals {
  docdb_cluster_instance_count = length(var.availability_zones)
}
