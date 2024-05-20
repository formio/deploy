

data "archive_file" "deployment_zip" {
  type        = "zip"
  source_dir  = "${path.root}/application-bundle"
  output_path = local.deployment_bundle_path
}

resource "aws_s3_object" "deployment_bundle" {
  bucket = var.deployment_s3_bucket
  key    = local.deployment_bundle
  source = local.deployment_bundle_path
}