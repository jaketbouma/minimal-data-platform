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
    use_lockfile   = true
    dynamodb_table = ""
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "bookstore"
  default_tags {
    tags = {
      "environment" = "sandbox"
      "deployment"  = "iac"
      "iac"         = "terraform/minimal-data-platform/bookstore"
    }
  }
}
