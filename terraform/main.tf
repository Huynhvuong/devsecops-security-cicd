# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.38.0"
    }
  }

  backend "s3" {
    encrypt        = true
    dynamodb_table = "vuonghuynh-poc-tfstate-table"
  }

}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
  assume_role {
    role_arn    = var.workspace_iam_roles[terraform.workspace]
    external_id = var.EXTERNAL_ID
  }
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  alias               = "aws-global"
  allowed_account_ids = [var.account_id]
  assume_role {
    role_arn    = var.workspace_iam_roles[terraform.workspace]
    external_id = var.EXTERNAL_ID
  }
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
