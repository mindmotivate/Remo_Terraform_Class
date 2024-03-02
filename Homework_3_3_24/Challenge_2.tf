# List Variable Definition:
variable "user_roles" {
  type        = list(string)
  description = "list of user roles"
  default     = ["admin", "editor", "viewer"]
}

# Resource Definition:
resource "local_file" "user_role_list" {
  count    = length(var.user_roles)
  filename = "${path.module}/user-role-${var.user_roles[count.index]}.txt"
  content  = "${var.user_roles[count.index]} user role"
}

# Individual Outputs for Each User Role:
output "user_role_0" {
  value = local_file.user_role_list[0].content
}

output "user_role_1" {
  value = local_file.user_role_list[1].content
}

output "user_role_2" {
  value = local_file.user_role_list[2].content
}

# Output for All User Roles:
output "user_roles_all" {
  value = [for instance in local_file.user_role_list : "${instance.filename}: ${instance.content}"]
}


# Map Variable Definition:
variable "feature_toggles" {
  description = "List of toggle features"
  type        = map(string)
  default     = {
    signup_enabled            = "true"
    profile_editing_enabled   = "false"
    search_functionality_enabled = "true"
  }
}

# Resource Definition Using each.key-value pair
resource "local_file" "feature_toggle_list" {
  for_each = var.feature_toggles
  filename = "${path.module}/feature-${each.key}.txt"
  content  = "${each.key}:${each.value}"
}

# Output for All Feature Toggles displays content of each local file resource created.
output "feature_toggle_list_output" {
  value = [
    for feature in local_file.feature_toggle_list : feature.content
  ]
}
