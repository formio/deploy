
# there is an issue passing availability_zones to docdb module, 
# https://github.com/hashicorp/terraform-provider-aws/issues/19451
resource "aws_docdb_cluster" "formio-docdb-cluster" {

  cluster_identifier = "formio-docdb-cluster"
  engine             = "docdb"
  engine_version     = "4.0.0"
  master_username    = var.master_username
  master_password    = var.master_password

  db_subnet_group_name   = aws_docdb_subnet_group.formio-docdb-subnet-group.name
  vpc_security_group_ids = [aws_security_group.formio-sg.id]
  apply_immediately      = var.apply_immediately
  skip_final_snapshot    = var.skip_final_snapshot
}
resource "aws_docdb_cluster_instance" "formio-docdb-instances" {
  count              = var.cluster_instance_count
  cluster_identifier = aws_docdb_cluster.formio-docdb-cluster.cluster_identifier
  instance_class     = var.ec2_instance_class
  identifier         = "formio-docdb-instance-${count.index}"
}

output "formio_private_securty_group_id" {
  value = aws_security_group.formio-sg.id
  
}

output "connection_string" {
  value = "mongodb://${var.master_username}:${var.master_password}@${aws_docdb_cluster.formio-docdb-cluster.endpoint}:27017/${var.database_name}?tls=true&retryWrites=false"

}