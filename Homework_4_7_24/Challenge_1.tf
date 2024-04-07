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



#--------Create this AFTER the statefile cofiguration has been created----------------------

#Variables.tf
# Define Variables
variable "document_storage_bucket_name" {
  description = "Name of the S3 bucket used for storing documents."
  type        = string
  default     = "document-storage-bucket987"
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket used for storing logs."
  type        = string
  default     = "logs-bucket654"
}

variable "document_access_role_name" {
  description = "Name of the IAM role with read-write access to the document storage bucket."
  type        = string
  default     = "document-access-role"
}

variable "logs_access_role_name" {
  description = "Name of the IAM role with read-only access to the logs bucket."
  type        = string
  default     = "logs-access-role"
}



#------------------------------------------------------------------------------------------------------------




# Create DynamoDB table for storing application data
resource "aws_dynamodb_table" "webapp_table" {
  name           = "webapp_data"        # Name of the DynamoDB table
  billing_mode   = "PAY_PER_REQUEST"    # Use on-demand billing mode
  hash_key       = "ID"                 # Define the hash key for the table

  attribute {
    name = "ID"
    type = "S"                          # Set the type of the hash key attribute
  }

  # Add more attributes as needed
}


# Create S3 bucket for document storage
resource "aws_s3_bucket" "document_storage" {
  bucket = var.document_storage_bucket_name
  force_destroy = true
}

# Enable versioning for the document storage bucket
resource "aws_s3_bucket_versioning" "document_storage_versioning" {
  bucket = aws_s3_bucket.document_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Create S3 bucket for storing logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name
  force_destroy=true
}

# Configure lifecycle policy for the logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id = "logs-transition-to-glacier"
    status = "Enabled"

    expiration {
      days = 365
    }

    transition {
      days = 30
      storage_class = "GLACIER"
    }
  }
}

# Define IAM role for document storage access
resource "aws_iam_role" "document_access_role" {
  name = var.document_access_role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Define IAM role for logs access
resource "aws_iam_role" "logs_access_role" {
  name = var.logs_access_role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

