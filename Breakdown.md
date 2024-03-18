### Creating an IAM Role with S3 Read-Only Access

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

## Ok, onto the next task...

Create a custom IAM policy named AssumeReadOnlyS3RolePolicy. This policy should allow an IAM user to perform the sts:AssumeRole action specifically on the ReadOnlyS3AccessRole.

Create the policy content which should specify that the sts:AssumeRole action is allowed, and it should target the ARN of the ReadOnlyS3AccessRole created in the previous step.

Note: "AmazonS3ReadOnlyAccess" is a pre-existing managed policy that is defined in aws already

### Defining a Custom IAM Policy to Assume the S3 Read-Only Access Role

1. **Policy Creation:**
   - **Question:** What are we creating?
   - **Answer:** We're making a policy called "AssumeReadOnlyS3RolePolicy" that outlines how an IAM user can borrow permissions from another role.

2. **Policy Content:**
   - **Question:** What does the policy say?
   - **Answer:** It says that the IAM user can temporarily borrow permissions from a role named "ReadOnlyS3AccessRole" specifically to access S3 (Amazon Simple Storage Service) in read-only mode. The only action permitted by this policy is to assume the permissions of the "ReadOnlyS3AccessRole" role.

3. **Specific Action Allowed:**
   - **Question:** What action is permitted by this policy?
   - **Answer:** The policy allows the IAM user to do one thing: assume the permissions of the "ReadOnlyS3AccessRole" role.

## Steps 1-3

```
resource "aws_iam_policy" "assume_read_only_s3_role_policy" {
  name   = "AssumeReadOnlyS3RolePolicy"
  policy = <<-EOF
  {
	"Version": "2012-10-17",
	"Statement": [
  	{
    	"Effect": "Allow",
    	"Action": "sts:AssumeRole",
    	"Resource": "${aws_iam_role.read_only_s3_access_role.arn}"
  	}
	]
  }
  EOF
}
```

### Ok next task...
Remo wants us to ... Create an IAM user named S3ReadOnlyUser.Attach the AssumeReadOnlyS3RolePolicy to this user. This setup allows the user to assume the ReadOnlyS3AccessRole, indirectly granting them read-only access to S3.

I interpret this as two tasks:

### To-Do List:

1. **Create IAM User:**
   - Create an IAM user named "S3ReadOnlyUser" using the `aws_iam_user` resource.

2. **Attach Custom Policy:**
   - Attach the previously defined custom IAM policy, "assume_read_only_s3_role_policy," to the newly created IAM user using the `aws_iam_user_policy_attachment` resource.
   - This attachment grants the IAM user the necessary permissions to assume the role specified in the custom policy.


Note: ARNs are frequently utilized in policy attachments to specify which policy should be linked to an IAM user, group, or role. In the Terraform code snippet, policy_arn = aws_iam_policy.assume_read_only_s3_role_policy.arn precisely identifies the ARN of the assume_read_only_s3_role_policy IAM policy for attachment, ensuring the user inherits its permissions

### Step 1
```
# IAM User creation
resource "aws_iam_user" "s3_read_only_user" {
  name = "S3ReadOnlyUser"
}
```

### Step 2
```
# Attach custom policy
resource "aws_iam_user_policy_attachment" "attach_assume_role_policy" {
  user       = aws_iam_user.s3_read_only_user.name
  policy_arn = aws_iam_policy.assume_read_only_s3_role_policy.arn
}

```

### Create these two Outputs:
- **Role ARN:** Output the Amazon Resource Name (ARN) of the ReadOnlyS3AccessRole.
- **User Name:** Output the name of the IAM user, S3ReadOnlyUser.
  
- **`aws_iam_role.read_only_s3_access_role.arn`:**
  - This line retrieves the ARN (Amazon Resource Name) of the IAM role named "read_only_s3_access_role". The `.arn` suffix is used to specify that we want the unique identifier for the role, which is useful for cross-resource references or sharing with other AWS services.

- **`aws_iam_user.s3_read_only_user.name`:**
  - This line fetches the name of the IAM user named "s3_read_only_user". The `.name` suffix indicates that we want the human-readable identifier for the user, which can be helpful for display purposes or naming other resources.

```
output "role_arn" {
  value = aws_iam_role.read_only_s3_access_role.arn
}
 
output "user_name" {
  value = aws_iam_user.s3_read_only_user.name
}
```

### Congrats! I think we completed the tasks! However, as Remo stated...there are many other ways to achieve this result!


