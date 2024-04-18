# Elastic Beanstalk 
This deploys the the application bundle to Elastic Beanstalk.  The application-bundle folder includes the docker-compose file, nginx configuration, and aws certificates necessary to connect to DocumentDB.

The script will generate a zip file of the application-bundle folder, push the zip file to an s3 bucket and update elastic beanstalk.

The deployment file and the the `application_version` resource are appeneded with the `app_version` variable.  So each deployment should have it's own deployment zip file and create a new elastic beanstalk version as well.  This should make it easier to reverty to an older version if necessary.

When using docker-compose with Elastic Beanstalk, EB will generate a .env file with the environment variables passed to.  Those should be the only source of truth for environment variables (not in the docker-compose.yml file).
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elastic_beanstalk_application.formio-app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application) | resource |
| [aws_elastic_beanstalk_application_version.formio-app-version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application_version) | resource |
| [aws_elastic_beanstalk_environment.env](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment) | resource |
| [aws_iam_instance_profile.eb_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.eb_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eb_WebTier_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eb_WorkerTier_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eb_health_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eb_multicontinter_docker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eb_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eb_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_object.deployment_bundle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.eb_app_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [archive_file.deployment_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.eb_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [admin\_email](#input\_admin\_email) | admin email | `string` | n/a | yes |
| [admin\_password](#input\_admin\_password) | admin password | `string` | n/a | yes |
| [app\_version](#input\_app\_version) | unique version label for the application deployment | `string` | n/a | yes |
| [asg\_max\_count](#input\_asg\_max\_count) | minimum number of instances in the auto scaling group | `number` | n/a | yes |
| [asg\_min\_count](#input\_asg\_min\_count) | minimum number of instances in the auto scaling group | `number` | n/a | yes |
| [db\_connection\_string](#input\_db\_connection\_string) | connection string to the database | `string` | n/a | yes |
| [deployment\_s3\_bucket](#input\_deployment\_s3\_bucket) | S3 bucket where deployment artifacts are stored | `string` | n/a | yes |
| [formio\_license\_key](#input\_formio\_license\_key) | formio license key | `string` | n/a | yes |
| [instance\_type](#input\_instance\_type) | instance type | `string` | n/a | yes |
| [jwt\_secret](#input\_jwt\_secret) | jwt token secret | `string` | n/a | yes |
| [pdf\_s3\_bucket](#input\_pdf\_s3\_bucket) | formio license key | `string` | n/a | yes |
| [pdf\_server](#input\_pdf\_server) | pdf server | `string` | `"http://pdf-server:4005"` | no |
| [port](#input\_port) | port | `number` | `3000` | no |
| [portal\_enabled](#input\_portal\_enabled) | portal enabled | `number` | `1` | no |
| [private\_security\_group\_id](#input\_private\_security\_group\_id) | security group that connects to vpc private subnets | `string` | n/a | yes |
| [private\_subnets](#input\_private\_subnets) | list of private subnet from | `list(string)` | n/a | yes |
| [public\_subnets](#input\_public\_subnets) | list of private subnet from | `list(string)` | n/a | yes |
| [s3\_region](#input\_s3\_region) | formio license key | `string` | n/a | yes |
| [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_archive_file_path"></a> [archive\_file\_path](#output\_archive\_file\_path) | n/a |
| <a name="output_eb_deployment_source"></a> [eb\_deployment\_source](#output\_eb\_deployment\_source) | n/a |
