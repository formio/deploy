<!-- BEGIN_TF_DOCS -->
## Elastic DocumentDB Cluster
Generates an Amazon Elastic DocumentDB Cluster.  Associated with the cluster, it will create a security group with an Ingress rule to allow traffic over port 27010.  Any resource that connects to the database will need to be in this security gorup.

*Known Issue with `availability_zones` parameter*
When building this script I hit  a known issue regarding the availability_zones, where it will randomaly attach a new AZ to the config, causing the resource to be rebuilt every time.  Excluding this parameter solved the problem.

This outputs the connection string and the security group id.
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.44.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_docdb_cluster.formio-docdb-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) | resource |
| [aws_docdb_cluster_instance.formio-docdb-instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance) | resource |
| [aws_docdb_subnet_group.formio-docdb-subnet-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_subnet_group) | resource |
| [aws_security_group.formio-sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.formio-eb-docdb-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|  [apply\_immediately](#input\_apply\_immediately) | Apply changes to infrastructure immediately,otherwise changes will be made at next maintenace window | `bool` | `true` | no |
|  [availability\_zones](#input\_availability\_zones) | Availability Zones | `list(string)` | n/a | yes |
|  [cluster\_instance\_count](#input\_cluster\_instance\_count) | Number of instances in the cluster | `number` | n/a | yes |
|  [database\_name](#input\_database\_name) | Name of the database | `string` | n/a | yes |
|  [ec2\_instance\_class](#input\_ec2\_instance\_class) | instance class of cluster instances | `string` | n/a | yes |
|  [master\_password](#input\_master\_password) | Master password for the cluster | `string` | n/a | yes |
|  [master\_username](#input\_master\_username) | Master username for the cluster | `string` | n/a | yes |
|  [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | when a cluster is deleted, a final snapshot is created if this parameter is set to false, otherwise no final snapshot is created.  Makes it easier when testing IaC changes. | `bool` | `true` | no |
|  [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |
|  [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR block | `string` | n/a | yes |
|  [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | The connection string to connect to the database.  Passed to the Elastic Beanstalk as an Environment Variable |
| <a name="output_formio_private_securty_group_id"></a> [formio\_private\_securty\_group\_id](#output\_formio\_private\_securty\_group\_id) | n/a |
<!-- END_TF_DOCS -->