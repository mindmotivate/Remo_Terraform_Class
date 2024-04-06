#Provider Block:

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}


#Remote State Terraform Configuration

# Create S3 bucket for hosting the Terraform state file
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket301"
  force_destroy = true
}

# Enable versioning for the Terraform state bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable ownership controls for the Terraform state bucket
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set ACL for the Terraform state bucket
resource "aws_s3_bucket_acl" "terraform_state" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform_state]
  bucket     = aws_s3_bucket.terraform_state.id
  acl        = "private"
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "state-locking"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
	name = "LockID"
	type = "S"
  }
}




