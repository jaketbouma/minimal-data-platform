data "aws_organizations_organization" "current" {}
data "aws_organizations_organizational_unit_child_accounts" "root_ous" {
  provider  = aws.mgmt
  parent_id = var.aws_ou_to_grant_data_lake_access
}
locals {
  aws_account_ids_to_grant_data_lake_access = { for account in data.aws_organizations_organizational_unit_child_accounts.root_ous.accounts : account.name => account.id if account.status == "ACTIVE" }
}

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


data "aws_iam_policy_document" "glue_catalog_policy" {
  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        for id in local.aws_account_ids_to_grant_data_lake_access:
        "arn:aws:iam::${id}:root"
      ]
    }
    resources = [
      "arn:aws:glue:${local.region}:${local.account_id}:catalog",
      "arn:aws:glue:${local.region}:${local.account_id}:database/demo"
    ]
  }
}
