resource "aws_security_group" "formio-sg" {
  vpc_id      = var.vpc_id
  name        = "formio-sg"
  description = "security group to connnect docdb and beanstalk"
}
resource "aws_vpc_security_group_ingress_rule" "formio-eb-docdb-ingress" {
  security_group_id = aws_security_group.formio-sg.id
  from_port         = 27017
  to_port           = 27017
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}
resource "aws_docdb_subnet_group" "formio-docdb-subnet-group" {
  subnet_ids  = var.subnet_ids
  name        = "formio-docdb-subnet-group"
  description = "formio docdb subnet group"
}