# Challenge: Secure AWS Environment Setup with Terraform

## Lets try to turn Remo's challenge into a series of word problems, one sentence at a time!

### Creating IAM Groups for Each Environment:

**Task:** "Define three IAM groups named Development, Staging, and Production."

**Question:** What groups are we creating?

**Answer:** We're creating IAM groups for different environments inluding: Development, Staging, and Production.

***I am thinking maybe we use a list string variable made up of the three environments?***
***This way when we create the IAM group resource we can reference those three groups dynamically (However, I am sure there are numerous ways to do this!)***

```hcl
# Define IAM Groups for each environment 
variable "environments" {
  description = "List of environment names"
  type        = list(string)
  default     = ["Development", "Staging", "Production"]
}
```

```hcl
# Create IAM groups dynamically
resource "aws_iam_group" "environment_groups" {
  for_each = toset(var.environments)

  name = each.key
}
```

```hcl
# Output details of each created group including: arn, name, path, id
output "environment_group_names" {
  value = values(aws_iam_group.environment_groups)
}
```

### Define Users:

**Task:** Set up a list of users, each indicating their role by their name prefix (e.g., DevMook, StagingRevan, ProdDack), and manually assign each to the correct group.

**Question:** How are users assigned to groups?

**Answer:** Users are manually assigned to the appropriate IAM groups based on their role and the environment they belong to.

***Perhaps we use another list string variable to express the users? It seems as if Remo has given us the preferred names so we can go with those: DevMook, StagingRevan, ProdDack***

```hcl
# Define Users with names provided by remo
variable "users" {
  description = "List of users with their respective roles"
  type        = list(string)
  default     = ["DevMook", "StagingRevan", "ProdDack"]
}
```

***Again, there are alot of ways to accomplsh this, I like using the count length function becasue it is a bit more straighforward***
***I simply want to manually iterate over each anme and attatch a group***

***The count parameter determines how many IAM users will be created. It's set to the length of the "users" list.***
***The name attribute of each IAM user is set to the corresponding user name from the "users" list.***
***During each iteration, count.index provides the current index value, starting from 0.***

```hcl
# Create Iam users via iteration using "count" parameter
resource "aws_iam_user" "users" {
  count = length(var.users)
  name  = var.users[count.index]
}
```
Now we have to manually assign each of the users we created to the correct group:
- Counting Users: We determine the number of users in the list and create a membership for each user.
- Membership Name: Each membership receives a unique name by appending "-membership" to the user's name.
- User Assignment: Users are assigned to memberships, with each membership containing only one IAM user.
- Group Assignment: IAM users are added to the IAM group associated with the proper environment.

### This method is NOT DRY!! I will need to revisit this and try to make it simpler but it gets the job done for now.

```hcl
resource "aws_iam_group_membership" "development_membership" {
  name     = "${var.users[0]}-membership"
  users    = [aws_iam_user.users[0].name]
  group    = aws_iam_group.environment_groups["Development"].name
}

resource "aws_iam_group_membership" "staging_membership" {
  name     = "${var.users[1]}-membership"
  users    = [aws_iam_user.users[1].name]
  group    = aws_iam_group.environment_groups["Staging"].name
}

resource "aws_iam_group_membership" "production_membership" {
  name     = "${var.users[2]}-membership"
  users    = [aws_iam_user.users[2].name]
  group    = aws_iam_group.environment_groups["Production"].name
}
```
If you want to create a simple output that provides a list of groups and their respective members, you can use this:

```hcl
output "group_memberships" {
  value = {
    "Development" = aws_iam_group_membership.development_membership
    "Staging"     = aws_iam_group_membership.staging_membership
    "Production"  = aws_iam_group_membership.production_membership
  }
}
```
***If your output looks good, go ahead an proceed to custom access policies next...***


## *Dry Approach
If you want to try to create the group membership resrouces dynamically using a DRY approach, you may want ot consider using the count = length argument.

1. Count Users: Determine the number of users and create a membership for each.
2. Membership Name: Generate a unique name for each membership.
3. User Assignment: Assign each user to a membership.
4. Group Assignment: Associate users with the correct IAM group based on their environment.

```hcl
resource "aws_iam_group_membership" "environment_memberships" {
  count = length(var.users)  # Create memberships for each user
  
  name  = "${var.users[count.index]}-membership"  # Generate unique membership name
  users = [aws_iam_user.users[count.index].name]  # Assign user to membership
  group = aws_iam_group.environment_groups[var.environments[count.index]].name  # Associate user with correct IAM group
}
```

### Custom Access Policies:

**Task:** Craft custom policies for each group, use both data source and define the policy directly.

**Question:** What access policies are being defined?

**Answer:** Custom access policies are defined for each environment specifying which actions users in those environments can perform on AWS resources.

Remo gave us an idea of the type of actions each policy should have:
Development: Grant EC2 actions, S3 list, and read operations.
Staging: Allow S3 read operations and viewing CloudWatch logs.
Production: Limit to S3 read operations only.

Look through the console and try to find the ones that best fit: (the following are just examples....)

**Development:**
- Grant EC2 actions:
  - [AmazonEC2FullAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_amazon-ec2-full-access)
  - [AmazonEC2ReadOnlyAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_amazon-ec2-read-only-access)
- S3 list and read operations:
  - [AmazonS3ReadOnlyAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_s3_read-only-console)

**Staging:**
- Allow S3 read operations:
  - [AmazonS3ReadOnlyAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_s3_read-only-console)
- Viewing CloudWatch logs:
  - [CloudWatchReadOnlyAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_cloudwatch-read-only-console)

**Production:**
- Limit to S3 read operations only:
  - [AmazonS3ReadOnlyAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_s3_read-only-console)


***Next, I simply took Remos' example from class and replaced the policy actions listed above:***
***This will define the polic documents***

```hcl
# Define custom policy documents for each environment
data "aws_iam_policy_document" "custom_policy_doc" {
  for_each = {
    development = {
      actions   = ["ec2:DescribeInstances", "ec2:StartInstances", "ec2:StopInstances", "s3:ListBucket", "s3:GetObject"]
      resources = ["*"]
    },
    staging = {
      actions   = ["s3:ListBucket", "s3:GetObject", "logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:GetLogEvents"]
      resources = ["arn:aws:s3:::example-staging-bucket/*"]
    },
    production = {
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::example-production-bucket/*"]
    }
  }
  statement {
    actions   = each.value.actions
    resources = each.value.resources
    effect    = "Allow"
  }
}
```
***No that we have created the policy documents, we can go ahead and create the policies (this was also taken directly from Remo's class example)***

```hcl
# Create custom IAM policies from policy documents
resource "aws_iam_policy" "custom_policy" {
  for_each = data.aws_iam_policy_document.custom_policy_doc
  name     = "${each.key}-policy"
  policy   = each.value.json
}
```

***Now for the policy atatchment (this was also taken directly from Remo's class example)***

```hcl
# Attach custom policies to IAM groups dynamically
resource "aws_iam_group_policy_attachment" "environment_policy_attachment" {
  for_each = aws_iam_group.environment_groups

  group      = each.key
  policy_arn = data.aws_iam_policy_document.custom_policy_doc[each.key].arn
}
```

## Assign Users to Groups:

**Task:** Manually ensure that each IAM user is a member of their respective group.
**Question:** How are the custom policies linked to the IAM groups?
**Answer:** The custom access policies are attached to the respective IAM groups to enforce the defined permissions for users in each environment.

```hcl
resource "aws_iam_group_membership" "development_membership" {
  count = length(var.users)

  name  = "${var.users[count.index]}-membership"
  users = [aws_iam_user.users[count.index].name]
  group = aws_iam_group.environment_groups["Development"].name
}
```

### Self Check Outputs:

**Task:** The Terraform configuration should output the ARNs of all created IAM users and groups for verification purposes.
**Question:** What information is being outputted?
**Answer:** The Amazon Resource Names (ARNs) of the created IAM users and groups are being outputted for reference and further use.

```hcl

output "user_arns" {
  value = [for user in aws_iam_user.users : user.arn]
}

output "group_arns" {
  value = [for group in aws_iam_group.environment_groups : group.arn]
}


```
