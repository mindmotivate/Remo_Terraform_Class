
/*
# Define in a seperate terraform.tfvars module
document_storage_bucket_name = "document-storage-bucket987"
logs_bucket_name = "logs-bucket654"
document_access_role_name = "document-access-role"
logs_access_role_name = "logs-access-role"
*/

# Define Variables
variable "document_storage_bucket_name" {
  description = "Name of the S3 bucket used for storing documents."
  type        = string
  default     = ""
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket used for storing logs."
  type        = string
  default     = ""
}

variable "document_access_role_name" {
  description = "Name of the IAM role with read-write access to the document storage bucket."
  type        = string
  default     = ""
}

variable "logs_access_role_name" {
  description = "Name of the IAM role with read-only access to the logs bucket."
  type        = string
  default     = ""
}


# Create S3 Buckets
# Create the S3 bucket for document storage
resource "aws_s3_bucket" "document_storage" {
  bucket = var.document_storage_bucket_name
  # region = "us-east-1"
}

# Create the S3 bucket for storing logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name
  # region = "us-east-1"
}

# Enable Versioning for Document Storage Bucket
# Enable versioning for the document storage bucket
resource "aws_s3_bucket_versioning" "document_storage_versioning" {
  bucket = aws_s3_bucket.document_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure Lifecycle Policy for Logs Bucket
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
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

# Define IAM Policies
# Define IAM policy for document storage bucket access
resource "aws_iam_policy" "document_storage_policy" {
  name        = "document-storage-policy"
  description = "Policy for document storage bucket access."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
      Resource  = [aws_s3_bucket.document_storage.arn, "${aws_s3_bucket.document_storage.arn}/*"]
    }]
  })
}

# Define IAM policy for logs bucket access
resource "aws_iam_policy" "logs_policy" {
  name        = "logs-policy"
  description = "Policy for logs bucket access."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = ["s3:GetObject"],
      Resource  = [aws_s3_bucket.logs_bucket.arn, "${aws_s3_bucket.logs_bucket.arn}/*"]
    }]
  })
}

# Create IAM Roles
# Create IAM role for document storage access
resource "aws_iam_role" "document_access_role" {
  name               = var.document_access_role_name
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

# Create IAM role for logs access
resource "aws_iam_role" "logs_access_role" {
  name               = var.logs_access_role_name
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

# Attach Policies to Roles
# Attach document storage policy to the document access role
resource "aws_iam_role_policy_attachment" "document_storage_attachment" {
  role       = aws_iam_role.document_access_role.name
  policy_arn = aws_iam_policy.document_storage_policy.arn
}

# Attach logs policy to the logs access role
resource "aws_iam_role_policy_attachment" "logs_attachment" {
  role       = aws_iam_role.logs_access_role.name
  policy_arn = aws_iam_policy.logs_policy.arn
}

# Output IAM Role ARNs and S3 Bucket Names
# Output the IAM role ARN for document access
output "document_access_role_arn" {
  value = aws_iam_role.document_access_role.arn
}

# Output the IAM role ARN for logs access
output "logs_access_role_arn" {
  value = aws_iam_role.logs_access_role.arn
}

# Output the document storage bucket name
output "document_storage_bucket_name" {
  value = aws_s3_bucket.document_storage.bucket
}

# Output the logs bucket name
output "logs_bucket_name" {
  value = aws_s3_bucket.logs_bucket.bucket
}

