terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tf-locking-state" {
  bucket = "terraform-state-locking-wordpress-production-786"
  # bucket = "terraform-state-locking-wordpress-production-786${random_string.suffix.result}"
}

resource "aws_s3_bucket_versioning" "tf-state-versioning" {
  bucket = aws_s3_bucket.tf-locking-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf-state-encryption" {
  bucket = aws_s3_bucket.tf-locking-state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# resource "aws_dynamodb_table" "statelock" {
#   name         = "state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# resource "random_string" "suffix" {
#   length  = 6
#   special = false
#   upper   = false
# }

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.tf-locking-state.id
}