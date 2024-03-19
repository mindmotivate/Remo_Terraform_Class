# Challenge: Secure AWS Environment Setup with Terraform

## Lets try to turn Remo's challenge in toa series of word problems, one sentence at a time!

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

```
# type this in the terminal to check your work
terraform output environment_groups
```

### Define Users:

**Task:** Set up a list of users, each indicating their role by their name prefix (e.g., DevMook, StagingRevan, ProdDack), and manually assign each to the correct group.
**Question:** How are users assigned to groups?
**Answer:** Users are manually assigned to the appropriate IAM groups based on their role and the environment they belong to.

### Custom Access Policies:

**Task:** Craft custom policies for each group, use both data source and define the policy directly.
**Question:** What access policies are being defined?
**Answer:** Custom access policies are defined for each environment specifying which actions users in those environments can perform on AWS resources.

### Assign Users to Groups:

**Task:** Manually ensure that each IAM user is a member of their respective group.
**Question:** How are the custom policies linked to the IAM groups?
**Answer:** The custom access policies are attached to the respective IAM groups to enforce the defined permissions for users in each environment.

### Outputs:

**Task:** The Terraform configuration should output the ARNs of all created IAM users and groups for verification purposes.
**Question:** What information is being outputted?
**Answer:** The Amazon Resource Names (ARNs) of the created IAM users and groups are being outputted for reference and further use.
