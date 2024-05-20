
module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "formio-tf-vpc"
  cidr               = var.cidr_block
  azs                = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = true
  enable_vpn_gateway = true


}
output "vpc_id" {
  value = module.aws_vpc.vpc_id
}
output "private_subnet_ids" {
  value = module.aws_vpc.private_subnets
}
output "public_subnet_ids" {
  value = module.aws_vpc.public_subnets
}