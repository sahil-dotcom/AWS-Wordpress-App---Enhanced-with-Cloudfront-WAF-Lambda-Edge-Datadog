terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-locking-wordpress-production-786"
    key    = "prod/app/terraform.tfstate"
    region = "us-east-1"
    # dynamodb_table = "state-lock"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}