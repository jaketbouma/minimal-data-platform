
resource "aws_identitystore_group" "marketplace_admins" {
  provider = aws.mgmt
  display_name      = "Marketplace administrators"
  description       = "Platform engineers building the marketplace"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "marketplace_shoppers" {
  provider = aws.mgmt
  display_name      = "Marketplace shoppers"
  description       = "Shoppers browsing all data in the marketplace and using basic tools"
  identity_store_id = local.identity_store_id
}

resource "aws_lakeformation_data_lake_settings" "platform" {
  admins = ["arn:aws:iam::${local.account_id}:role/Admin"]
}


resource "aws_glue_catalog_database" "platform" {
  name        = "platform"
  catalog_id  = local.account_id
  description = "Glue database for platform-related datasets"
}

resource "aws_glue_catalog_database" "sandbox" {
  name        = "sandbox"
  catalog_id  = local.account_id
  description = "Default glue catalog database for developing integrations"
}


resource "aws_athena_workgroup" "sandbox" {
  name = "sandbox"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.demo.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
  tags = {
    Environment = "Sandbox"
  }
}
