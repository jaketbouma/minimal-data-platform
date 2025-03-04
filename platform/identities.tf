#
# Identity center groups
resource "aws_identitystore_group" "marketplace_admins" {
  provider          = aws.mgmt
  display_name      = "Marketplace administrators"
  description       = "Platform engineers building the marketplace"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "marketplace_shoppers" {
  provider          = aws.mgmt
  display_name      = "Marketplace shoppers"
  description       = "Shoppers browsing all data in the marketplace and using basic tools"
  identity_store_id = local.identity_store_id
}

# Create an Identity Store group for lakeformation admins
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
# Create an Identity Store group for data engineers
resource "aws_identitystore_group" "lakeformation_data_engineers" {
  provider          = aws.mgmt
  identity_store_id = local.identity_store_id
  display_name      = "platform.lakeformation_data_engineers"
}
resource "aws_identitystore_group_membership" "lakeformation_data_engineers_membership" {
  provider          = aws.mgmt
  for_each          = toset(var.aws_idc_lakeformation_data_engineers_user_ids)
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.lakeformation_data_engineers.group_id
  member_id         = each.key
}


#
# Permission sets for data lake admins
# from https://docs.aws.amazon.com/lake-formation/latest/dg/permissions-reference.html

resource "aws_ssoadmin_permission_set" "lakeformation_admin" {
  provider = aws.mgmt

  instance_arn     = local.identity_store_arn
  name             = "LFAdminPermissionSet"
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

resource "aws_ssoadmin_permission_set_inline_policy" "lakeformation_admin_inline_policies" {
  provider = aws.mgmt

  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.lakeformation_admin.arn
  inline_policy      = data.aws_iam_policy_document.lakeformation_admin_inline_policies.json
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


# Permission sets for data engineers
# from https://docs.aws.amazon.com/lake-formation/latest/dg/permissions-reference.html

resource "aws_ssoadmin_permission_set" "lakeformation_data_engineer" {
  provider = aws.mgmt

  instance_arn     = local.identity_store_arn
  name             = "LFDataEngineerPermissionSet"
  description      = "Lakeformation data engineer permissions"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "lakeformation_data_engineer_managed_policies" {
  provider = aws.mgmt

  for_each = {
    AWSLakeFormationDataAdmin    = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin",
    AWSGlueConsoleFullAccess     = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    CloudWatchLogsReadOnlyAccess = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess",
    AmazonAthenaFullAccess       = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
  }
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.lakeformation_data_engineer.arn
  managed_policy_arn = each.value
}

data "aws_iam_policy_document" "lakeformation_data_engineer_inline_policies" {
  # Inline policy (basic)
  statement {
    effect = "Allow"
    actions = [
      "lakeformation:GetDataAccess",
      "lakeformation:GrantPermissions",
      "lakeformation:RevokePermissions",
      "lakeformation:BatchGrantPermissions",
      "lakeformation:BatchRevokePermissions",
      "lakeformation:ListPermissions",
      "lakeformation:AddLFTagsToResource",
      "lakeformation:RemoveLFTagsFromResource",
      "lakeformation:GetResourceLFTags",
      "lakeformation:ListLFTags",
      "lakeformation:GetLFTag",
      "lakeformation:SearchTablesByLFTags",
      "lakeformation:SearchDatabasesByLFTags",
      "lakeformation:GetWorkUnits",
      "lakeformation:GetWorkUnitResults",
      "lakeformation:StartQueryPlanning",
      "lakeformation:GetQueryState",
      "lakeformation:GetQueryStatistics"
    ]
    resources = ["*"]
  }
  # Inline policy (for operations on governed tables, including operations within transactions)	
  statement {
    effect = "Allow"
    actions = [
      "lakeformation:StartTransaction",
      "lakeformation:CommitTransaction",
      "lakeformation:CancelTransaction",
      "lakeformation:ExtendTransaction",
      "lakeformation:DescribeTransaction",
      "lakeformation:ListTransactions",
      "lakeformation:GetTableObjects",
      "lakeformation:UpdateTableObjects",
      "lakeformation:DeleteObjectsOnCancel"
    ]
    resources = ["*"]
  }
  # Inline policy (for metadata access control using the Lake Formation tag-based access control (LF-TBAC) method)
  statement {
    effect = "Allow"
    actions = [
      "lakeformation:AddLFTagsToResource",
      "lakeformation:RemoveLFTagsFromResource",
      "lakeformation:GetResourceLFTags",
      "lakeformation:ListLFTags",
      "lakeformation:GetLFTag",
      "lakeformation:SearchTablesByLFTags",
      "lakeformation:SearchDatabasesByLFTags"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase"
    ]
    resources = [
      "arn:aws:glue:eu-north-1:${local.account_id}:catalog",
      "arn:aws:glue:eu-north-1:${local.account_id}:database/*"
    ]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "lakeformation_data_engineer_inline_policies" {
  provider = aws.mgmt

  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.lakeformation_data_engineer.arn
  inline_policy      = data.aws_iam_policy_document.lakeformation_data_engineer_inline_policies.json
}

resource "aws_ssoadmin_account_assignment" "lakeformation_data_engineer" {
  for_each = local.aws_account_ids_to_grant_data_lake_access
  provider = aws.mgmt

  instance_arn = local.identity_store_arn

  permission_set_arn = aws_ssoadmin_permission_set.lakeformation_data_engineer.arn

  principal_id   = aws_identitystore_group.lakeformation_data_engineers.group_id
  principal_type = "GROUP"

  target_id   = each.value
  target_type = "AWS_ACCOUNT"
}
