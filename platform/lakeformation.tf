
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
locals {
  sso_terraform_developers_role_arn = data.aws_iam_session_context.current.issuer_arn
}


resource "aws_glue_catalog_database" "platform" {
  name        = "platform"
  catalog_id  = local.account_id
  description = "Glue database for platform-related datasets"
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


/*

locals {
  #organization_id = data.aws_organizations_organization.current.id
  lakeformation_identity_center_configuration_cli_json = {
    "CatalogId" : local.account_id
    "InstanceArn" : local.identity_store_arn
    "ShareRecipients": [
        {"DataLakePrincipalIdentifier": data.aws_organizations_organization.current.arn}
    ]
  }
}
resource "null_resource" "lakeformation_identity_center_configuration" {
  # https://github.com/hashicorp/terraform-provider-aws/issues/35260
  provisioner "local-exec" {
    command = <<EOT
    aws lakeformation delete-lake-formation-identity-center-configuration \
        --profile platform \
        --catalog-id '${local.account_id}' || true
    aws lakeformation create-lake-formation-identity-center-configuration \
        --profile platform \
        --cli-input-json '${jsonencode(local.lakeformation_identity_center_configuration_cli_json)}'
    EOT
  }
  triggers = {"cmd": jsonencode(local.lakeformation_identity_center_configuration_cli_json)}
  depends_on = [aws_lakeformation_data_lake_settings.platform]
}

*/