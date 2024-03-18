### Step 1: Creating an IAM Role with S3 Read-Only Access

1. **IAM Role Creation:**
   - **Question:** What role are we creating?
   - **Answer:** "ReadOnlyS3AccessRole" with S3 Read-Only Access.

2. **Trust Policy:**
   - **Question:** Who is trusted to assume this role?
   - **Answer:** The root user of the AWS account (`arn:aws:iam::${var.aws_account_id}:root`) is trusted to assume the role for temporary access.

3. **Policy Attachment:**
   - **Question:** Which policies should be attached to this role?
   - **Answer:** "AmazonS3ReadOnlyAccess" policy is attached, granting read-only access to S3 resources.
  
## Ok now that we have a basic word problem, let's figure it out

Creating an IAM role in AWS is like defining a new job position with certain responsibilities and giving someone (or something) 
the authority to perform those tasks within your AWS account.

The trust policy allows certain entities (specified by the AWS account ID) to assume the role, but only temporarily. 
This temporary access is granted through the "sts:AssumeRole" action, which means users can temporarily "become" this role and inherit its permissions. 
However, once their task is done or their time limit expires, their access is automatically revoked. 
This helps ensure security and follows the principle of least privilege, as users only have access to resources for the duration they actually need it.


We create an IAM role named "ReadOnlyS3AccessRole" that allows IAM users within the AWS account to assume it.
A trust policy is defined to allow the root user of the AWS account (specified by ${var.aws_account_id}) to assume this role.

## Step 1 & Step 2
```
resource "aws_iam_role" "read_only_s3_access_role" {
  name = "ReadOnlyS3AccessRole"
  assume_role_policy = <<-EOF
  {
	"Version": "2012-10-17",
	"Statement": [
  	{
    	"Effect": "Allow",
    	"Principal": {
      	"AWS": "arn:aws:iam::${var.aws_account_id}:root" # allows any user within the AWS account to assume the IAM role.
    	},
    	"Action": "sts:AssumeRole"
  	}
	]
  }
  EOF
}
```

The AWS-managed policy "AmazonS3ReadOnlyAccess" is attached to this role, granting read-only access to S3 resources.

## Step 3
```
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.read_only_s3_access_role.name # By using .name, you're specifying that you want to use the name of that IAM role resource when referencing it in other parts of your Terraform configuration
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # refers to a pre-defined AWS managed policy called "AmazonS3ReadOnlyAccess"
}
```






### Step 2: Defining a Custom IAM Policy to Assume the Role

1. **IAM Policy Definition:**
   - **Question:** What actions should this policy allow?
   - **Answer:** The policy allows the `sts:AssumeRole` action on the `ReadOnlyS3AccessRole`, specifying that IAM users within the AWS account can assume this role.
