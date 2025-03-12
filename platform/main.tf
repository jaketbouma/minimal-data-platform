data "aws_organizations_organization" "current" {}

locals {
  project_short_name = "platform"
  region = "eu-north-1"
}

#
# Athena
resource "aws_s3_bucket" "athena" {
  bucket_prefix = "athena-${local.project_short_name}"
  force_destroy = true
}
resource "aws_athena_workgroup" "playground" {
  name = "playground"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena.id}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
  tags = {
    Environment = "Sandbox"
  }
  force_destroy = true
}
