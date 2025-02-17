
#
# Lakeformation (doge)
#
# Create an Identity Store group for terraform developers
resource "aws_identitystore_group" "lakeformation_admins" {
  provider          = aws.mgmt
  identity_store_id = local.identity_store_id
  display_name      = "platform.lakeformation_admins"
}
resource "aws_identitystore_group_membership" "lakeformation_admins_membership" {
  provider          = aws.mgmt
  for_each          = toset(var.aws_idc_lakeformation_admin_user_ids)
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.lakeformation_admins.group_id
  member_id         = each.key
}

#
# Permission sets for data lake admins
# from https://docs.aws.amazon.com/lake-formation/latest/dg/permissions-reference.html

resource "aws_ssoadmin_permission_set" "lakeformation_admin" {
  provider = aws.mgmt

  instance_arn     = local.identity_store_arn
  name             = "LakeformationAdminPermissionSet"
  description      = "Lakeformation admin permissions"
  session_duration = "PT8H"
}
resource "aws_ssoadmin_managed_policy_attachment" "lakeformation_admin_managed_policies" {
  provider = aws.mgmt

  for_each = {
    AWSLakeFormationDataAdmin = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin",
    # this one's for services ;)
    #LakeFormationDataAccessServiceRolePolicy = "arn:aws:iam::aws:policy/aws-service-role/LakeFormationDataAccessServiceRolePolicy",
    AWSGlueConsoleFullAccess            = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    CloudWatchLogsReadOnlyAccess        = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess",
    AWSLakeFormationCrossAccountManager = "arn:aws:iam::aws:policy/AWSLakeFormationCrossAccountManager",
    AmazonAthenaFullAccess              = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
  }
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.lakeformation_admin.arn
  managed_policy_arn = each.value
}
data "aws_iam_policy_document" "lakeformation_admin_inline_policies" {
  # Inline policy (for creating the Lake Formation service-linked role)
  statement {
    effect = "Allow"
    actions = [
      "ram:AcceptResourceShareInvitation",
      "ram:RejectResourceShareInvitation",
      "ec2:DescribeAvailabilityZones",
      "ram:EnableSharingWithAwsOrganization"
    ]
    resources = ["*"]
  }
  # (Optional) Inline policy (passrole policy for the workflow role). This is required only if the data lake administrator creates and runs workflows.
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["lakeformation.amazonaws.com"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PutRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
    ]
  }
  #(Optional) Inline policy (if your account is granting or receiving cross-account Lake Formation permissions). This policy is for accepting or rejecting AWS RAM resource share invitations, and for enabling the granting of cross-account permissions to organizations. ram:EnableSharingWithAwsOrganization is required only for data lake administrators in the AWS Organizations management account.
  statement {
    effect = "Allow"
    actions = [
      "ram:AcceptResourceShareInvitation",
      "ram:RejectResourceShareInvitation",
      "ec2:DescribeAvailabilityZones",
      "ram:EnableSharingWithAwsOrganization"
    ]
    resources = ["*"]
  }
}

resource "aws_ssoadmin_account_assignment" "lakeformation_admin" {
  provider = aws.mgmt

  instance_arn = local.identity_store_arn

  permission_set_arn = aws_ssoadmin_permission_set.lakeformation_admin.arn

  principal_id   = aws_identitystore_group.lakeformation_admins.group_id
  principal_type = "GROUP"

  target_id   = local.account_id
  target_type = "AWS_ACCOUNT"
}



data "aws_iam_roles" "sso_lakeformation_admin" {
  name_regex  = "AWSReservedSSO_${aws_ssoadmin_permission_set.lakeformation_admin.name}_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
locals {
  sso_lakeformation_admin_role_arn  = one(data.aws_iam_roles.sso_lakeformation_admin.arns)
  sso_terraform_developers_role_arn = data.aws_iam_session_context.current.issuer_arn
}

#
# configuring lakeformation
#  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions#example-usage
resource "aws_lakeformation_data_lake_settings" "version" {
  # terraform_developers and lakeformation_admins will get admin
  admins = [local.sso_lakeformation_admin_role_arn, local.sso_terraform_developers_role_arn]

  #create_database_default_permissions {
  #  permissions = ["SELECT", "ALTER", "DROP"]
  #  principal   = local.sso_lakeformation_admin_role_arn
  #}

  #create_table_default_permissions {
  #  permissions = ["ALL"]
  #  principal   = local.sso_lakeformation_admin_role_arn
  #}

}