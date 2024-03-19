# Environment Specific IAM Groups

### Create IAM groups for three different environments: Development, Staging, and Production. Each group should have different permission levels appropriate for their environment. Then, dynamically create multiple users and assign them to these groups based on variables.
# Step 1: Define Variables for Usernames and Environments

Question: What are we defining?

Answer: We're setting up variables to keep track of user names and their corresponding environments.

Question: What kind of variables are we using?

Answer: We're using a map to associate each user with their respective environment.

# Step 2: Create IAM Groups with Different Policies (AWS-Managed)

Question: What are we creating?

Answer: We're creating IAM groups for different environments, such as Development, Staging, and Production, each with its own set of permissions.

Question: What policies are we attaching to these groups?

Answer: We're attaching AWS-managed policies to each group based on their environment's needs.

# Step 3: Create Users and Assign Them to Groups

Question: What users are we creating?

Answer: We're dynamically creating multiple users based on the defined variables.

Question: How are we assigning users to groups?

Answer: We're assigning users to their respective groups based on the environment specified in the variables.




## Step 1: Define Variables for Usernames and Environments

```hcl
# Define variables for users and environments
variable "users" {
  type        = map(string)  # Map data structure chosen to associate each user with their corresponding environment
  default     = {  # Default users
    Mook  = "development"
    Revan = "staging"
    Dack  = "production"
  }
} 

# Define variables for environment policies
variable "environment_policies" {
  type        = map(string)  # Map data structure chosen to associate each environment with its corresponding policy ARN
  default     = {  # Default policies
    development = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"  # Predefined AWS policy for granting full access to Amazon EC2 in development environment
    staging     = "arn:aws:iam::aws:policy/ReadOnlyAccess"       # Predefined AWS policy for read-only access in staging environment
    production  = "arn:aws:iam::aws:policy/AmazonS3FullAccess"   # Predefined AWS policy for granting full access to Amazon S3 in production environment
  }
}
# Using ARNs (Amazon Resource Names) is common because they provide a unique identifier for AWS resources,
# making it easy to reference specific resources across different AWS services and regions within the same AWS account
# ARNs can be obtained from the AWS Management Console. In the IAM (Identity and Access Management) section,
# you can navigate to the specific policy, role, user, or other resource, and the ARN will be displayed in the resource details.






```

## Step 2: Create IAM Groups with Different Policies (AWS-Managed)

```hcl
resource "aws_iam_group" "environment_group" {
  for_each = var.environment_policies
  name     = "${each.key}-group"
}

resource "aws_iam_group_policy_attachment" "group_policy_attach" {
  for_each   = var.environment_policies
  group      = aws_iam_group.environment_group[each.key].name
  policy_arn = each.value
}
```

## Step 3: Create Users and Assign Them to Groups

```hcl
resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.key
}

resource "aws_iam_group_membership" "user_group_membership" {
  for_each = var.users
  name     = "${each.key}-membership"
  users    = [aws_iam_user.users[each.key].name]
  group    = "${each.value}-group"
}
```

