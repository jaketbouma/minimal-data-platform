terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-statefiles"
    key            = "bookstore/terraform.tfstate"
    region         = "eu-north-1"
    profile        = "root/AdministratorAccess"  # fix me!
    use_lockfile   = true
    dynamodb_table = "terraform.statelock.bookstore"
  }
}

provider "aws" {
  region              = "eu-north-1"
  profile             = "bookstore"
  default_tags {
    tags = {
      "environment" = "sandbox"
      "deployment"  = "iac"
      "iac"         = "terraform/minimal-data-platform/bookstore"
    }
  }
}
