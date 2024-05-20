<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.formio-resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.pdf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pdf_s3_bucket"></a> [pdf\_s3\_bucket](#input\_pdf\_s3\_bucket) | S3 bucket for pdf resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_formio_resources_bucket"></a> [formio\_resources\_bucket](#output\_formio\_resources\_bucket) | n/a |
<!-- END_TF_DOCS -->