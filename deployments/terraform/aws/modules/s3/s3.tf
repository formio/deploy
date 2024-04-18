resource "aws_s3_bucket" "formio-resources" {
  bucket              = "formio-resources"
  object_lock_enabled = true
}
resource "aws_s3_bucket" "pdf_bucket" {
  bucket              = var.pdf_s3_bucket

}


output "formio_resources_bucket" {
  value = aws_s3_bucket.formio-resources.bucket
}
