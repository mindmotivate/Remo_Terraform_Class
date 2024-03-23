# Define IAM Groups for each environment 
variable "environments" {
  description = "List of environment names"
  type        = list(string)
  default     = ["development", "staging", "production"]
}
# Create IAM groups dynamically
resource "aws_iam_group" "environment_groups" {
  for_each = toset(var.environments)

  name = each.key
}


# Output details of eacg created group including: arn, name, path, id
output "environment_group_names" {
  value = values(aws_iam_group.environment_groups)
}



# this output will also return the detail about each group, you can individualize them if you choose
output "environment_group_names2" {
  value = concat([
    aws_iam_group.environment_groups["development"],
    aws_iam_group.environment_groups["staging"],
    aws_iam_group.environment_groups["production"]
  ])
}


# This output will only return thename sof the groups
output "environment_group_names3" {
  value = concat([
    aws_iam_group.environment_groups["development"].name,
    aws_iam_group.environment_groups["staging"].name,
    aws_iam_group.environment_groups["production"].name
  ])
}


# Define list of users
variable "users" {
  description = "List of users with their role name prefix"
  type        = list(string)
  default     = ["DevMook", "StagingRevan", "ProdDack"]
}

# Create Iam users via iteration using "count"
resource "aws_iam_user" "users" {
  count = length(var.users)
  name  = var.users[count.index]
}

resource "aws_iam_group_membership" "environment_memberships" {
  count = length(var.users)  # Create memberships for each user

  name  = "${var.users[count.index]}-membership"  # Generate unique membership name
  users = [aws_iam_user.users[count.index].name]  # Assign user to membership
  group = aws_iam_group.environment_groups[var.environments[count.index]].name  # Associate user with correct IAM group
}


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

# Create custom IAM policies from policy documents
resource "aws_iam_policy" "custom_policy" {
  for_each = data.aws_iam_policy_document.custom_policy_doc
  name     = "${each.key}-policy"
  policy   = each.value.json
}

# Attatch policies
resource "aws_iam_group_policy_attachment" "custom_group_policy_attach" {
  for_each   = aws_iam_policy.custom_policy

  group      = aws_iam_group.environment_groups[each.key].name
  policy_arn = each.value.arn
}

#arn outputs
output "user_arns" {
  value = [for user in aws_iam_user.users : user.arn]
}

output "group_arns" {
  value = [for group in aws_iam_group.environment_groups : group.arn]
}

#name outputs
output "user_names" {
  value = [for user in aws_iam_user.users : user.name]
}

output "group_names" {
  value = [for group in aws_iam_group.environment_groups : group.name]
}
