#variable "mgmt_account_role_arn" {
#  description = "The ARN of the management account role used for statefile and iac access"
#  type        = string
#}
variable "aws_idc_lakeformation_admin_user_ids" {
  description = "A list of Identity Center user IDs that will be in the lakeformation admins group"
  type        = list(string)
}
variable "aws_idc_lakeformation_data_engineers_user_ids" {
  description = "A list of Identity Center user IDs that will be in the lakeformation data engineers group"
  type        = list(string)
}
variable "aws_ou_to_grant_data_lake_access" {
  description = "The OU to grant data lake access to"
  type        = string
}