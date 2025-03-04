
data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  sso_terraform_developers_role_arn = data.aws_iam_session_context.current.issuer_arn
}

#
# configuring lakeformation
#  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions#example-usage
resource "aws_lakeformation_data_lake_settings" "platform" {
  # terraform_developers and lakeformation_admins will get admin
  admins     = [local.sso_terraform_developers_role_arn]
  catalog_id = local.account_id
  parameters = {
    "CROSS_ACCOUNT_VERSION" = "4"
  }
}

resource "aws_athena_workgroup" "sandbox" {
  name = "sandbox"

  configuration {
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.bookstore.bucket}/output/"

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

resource "aws_athena_data_catalog" "example" {
  name        = "marketplace"
  description = "Marketplace data platform from the platform account"
  type        = "GLUE"

  parameters = {
    "catalog-id" = var.platform_account_id
  }
}