variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"

}
variable "vpc_id" {
  type        = string
  description = "VPC ID"

}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"

}

variable "cluster_instance_count" {
  type        = number
  description = "Number of instances in the cluster"

}

variable "master_username" {
  type        = string
  description = "Master username for the cluster"

}

variable "master_password" {
  type        = string
  description = "Master password for the cluster"

}

variable "ec2_instance_class" {
  type        = string
  description = "instance class of cluster instances"

}
variable "apply_immediately" {
  type        = bool
  description = "Apply changes to infrastructure immediately,otherwise changes will be made at next maintenace window"
  default     = true

}

variable "skip_final_snapshot" {
  type        = bool
  description = "when a cluster is deleted, a final snapshot is created if this parameter is set to false, otherwise no final snapshot is created.  Makes it easier when testing IaC changes."
  default     = true
}
variable "database_name" {
  type        = string
  description = "Name of the database"

}
