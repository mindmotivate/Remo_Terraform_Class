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

# Create an S3 bucket to store Terraform state
resource "aws_s3_bucket" "terraform_state" {
  # Set the desired bucket name
  bucket = "terraform-state-bucket301"

  # Allow Terraform to completely remove the bucket during destruction
  force_destroy = true
}

# Create a DynamoDB table for state locking
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

# Create an IAM role for accessing the DynamoDB table
resource "aws_iam_role" "state_lock_role" {
  # Set the role name
  name = "state-lock-role"

  # Define a policy to allow S3 to assume this role for state locking
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

# Create an IAM policy for interacting with the DynamoDB table
resource "aws_iam_policy" "state_locking_policy" {
  # Set the policy name
  name        = "state-locking-policy"
  description = "Policy for state locking DynamoDB table"

  # Define the policy document to grant access to DynamoDB actions
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
      Resource = aws_dynamodb_table.terraform_state_lock.arn,
    }]
  })
}

# Attach the state locking policy to the IAM role
resource "aws_iam_policy_attachment" "attach_state_locking_policy" {
  # Set the attachment name
  name        = "state-locking-policy-attachment"

  # Reference the ARN of the state locking policy
  policy_arn  = aws_iam_policy.state_locking_policy.arn

  # Specify the role to attach the policy to (used for DynamoDB access)
  roles       = [aws_iam_role.state_lock_role.name]
}
