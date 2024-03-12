# Requirements

#IAM role named "ReadOnlyS3AccessRole"
#This role will have a trust policy allowing any IAM user within your account to assume it.

#The AWS-managed policy "AmazonS3ReadOnlyAccess" will be attached to the role, granting it read-only access to S3 resources.
#Custom Policy for Role Assumption:

#Custom IAM policy named "AssumeReadOnlyS3RolePolicy"
#This policy allows IAM users to perform the "sts:AssumeRole" action specifically on the "ReadOnlyS3AccessRole".
#The policy will target the ARN (unique identifier) of the "ReadOnlyS3AccessRole".

#IAM user named "S3ReadOnlyUser" 

#The "AssumeReadOnlyS3RolePolicy" will be attached to this user.
#This allows the user to assume the "ReadOnlyS3AccessRole", indirectly granting them read-only access to S3.

#Output the ARN of the "ReadOnlyS3AccessRole".

#Output the name of the IAM user, "S3ReadOnlyUser".


# Terraform Code


# Dynamically pull current account id
data "aws_caller_identity" "current" {}


# Create an IAM role named ReadOnlyS3AccessRole. 
# This role should have a trust policy that allows IAM users within your AWS account to assume it.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/


resource "aws_iam_role" "readonly_s3_access_role" {
  name               = "ReadOnlyS3AccessRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
      Effect    = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}


# Attach AWS managed policy for read-only S3 access
# https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonS3ReadOnlyAccess.html
resource "aws_iam_policy_attachment" "s3_readonly_policy_attachment" {
  name       = "s3_readonly_policy_attachment"
  roles      = [aws_iam_role.readonly_s3_access_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# Define custom IAM policy to assume role
resource "aws_iam_policy" "assume_role_policy" {
  name        = "AssumeReadOnlyS3RolePolicy"
  description = "Allows IAM user to assume ReadOnlyS3AccessRole"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Resource  = aws_iam_role.readonly_s3_access_role.arn
    }]
  })
}

# Create IAM user
resource "aws_iam_user" "s3_readonly_user" {
  name = "S3ReadOnlyUser"
}

# Attach custom IAM policy to IAM user
resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.s3_readonly_user.name
  policy_arn = aws_iam_policy.assume_role_policy.arn
}

# Outputs for arn
output "role_arn" {
  value = aws_iam_role.readonly_s3_access_role.arn
}

# Outputs for user name
output "user_name" {
  value = aws_iam_user.s3_readonly_user.name
}
