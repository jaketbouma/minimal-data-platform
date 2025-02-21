terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
  }

  backend "s3" {
    bucket         = ""
    key            = ""
    region         = ""
    profile        = ""
    assume_role    = ""
    use_lockfile   = true
    dynamodb_table = "terraform.statelock.platform"
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "platform"
  default_tags {
    tags = {
      "project"     = "platform"
      "environment" = "sandbox"
      "deployment"  = "iac"
      "iac"         = "terraform/minimal-data-platform/platform"
    }
  }
}

provider "aws" {
  alias   = "mgmt"
  region  = "eu-north-1"
  profile = "platform"
  assume_role {
    role_arn = var.mgmt_account_role_arn
  }
  default_tags {
    tags = {
      "project"     = "platform"
      "environment" = "sandbox"
      "deployment"  = "iac"
      "iac"         = "terraform/minimal-data-platform/platform"
    }
  }
}

#
# Grab some stuff that could also have been vars

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_ssoadmin_instances" "all" {}

locals {
  identity_store_id  = one(data.aws_ssoadmin_instances.all.identity_store_ids)
  identity_store_arn = one(data.aws_ssoadmin_instances.all.arns)
}
