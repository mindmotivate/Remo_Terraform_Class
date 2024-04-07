
# Note: This code is run seperately from the inial remoe state configuration setup! It assumes tha the s3 bucket for the remote statefiel has been created
# Configure Terraform to use the AWS provider
terraform {
  required_providers {
    aws = {
      # Define the source and version for the AWS provider plugin
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Set the AWS region where resources will be created
provider "aws" {
  region = "us-east-1"
}

# Commented-out backend configuration (commented for clarity)
/*
backend "s3" {
  bucket     = "terraform-state-bucket301"
  key       = "backend/terraform.tfstate"
  dynamodb_table = "state-locking"
  encrypt    = true
  region     = "us-east-1"
}
*/

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  # Set the table name
  name           = "state-locking"
  # Set billing mode (PAY_PER_REQUEST is cost-effective for infrequent locking)
  billing_mode   = "PAY_PER_REQUEST"
  # Define the hash key for locking (LockID is a common choice)
  hash_key       = "LockID"

  # Define the schema for the LockID attribute (String type)
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Create S3 bucket for hosting the Terraform state file
resource "aws_s3_bucket" "terraform_state" {
  # Set the desired bucket name
  bucket = "terraform-state-bucket301"

  # Allow Terraform to completely remove the bucket during destruction
  force_destroy = true
}

# Enable versioning for the Terraform state bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.terraform_state.bucket

  versioning_configuration {
    # Enable versioning for the bucket
    status = "Enabled"
  }
}

# Enable ownership controls for the Terraform state bucket
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    # Set object ownership to the bucket owner
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set ACL for the Terraform state bucket (private access)
resource "aws_s3_bucket_acl" "terraform_state" {
  # This resource depends on ownership controls being set
  depends_on = [aws_s3_bucket_ownership_controls.terraform_state]

  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.terraform_state.id
  # Set the ACL to private
  acl    = "private"
}

# Define IAM role for the state locking
resource "aws_iam_role" "state_lock_role" {
  # Provide a meaningful name for the role
  name = "state-lock-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect  = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Action  = "sts:AssumeRole"
    }]
  })
}

# Define IAM role policy for accessing the DynamoDB table
resource "aws_iam_role_policy" "dynamodb_access_policy" {
  # Set the policy name
  name = "dynamodb-access-policy"

  # Reference the IAM role created above
  role = aws_iam_role.state_lock_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect  = "Allow",
      Action  = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
      ],
      Resource = aws_iam_dynamodb_table.terraform_state_lock.arn,
    }]
  })
}
