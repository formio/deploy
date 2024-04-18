variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"

}
variable "public_subnets" {
  type        = list(string)
  description = "public subnet cidr blocks"
}

variable "private_subnets" {
  type        = list(string)
  description = "private subnet cidr blocks"
}
variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
}