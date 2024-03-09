/*
Challenge 2: Feature Toggle Management
Task:
Define a variable named feature_toggles as a map in variables.tf with arbitrary feature flags and their boolean states as strings. 
Hint – feature flags can be UI, beta access, etc…
*/



variable "feature_toggles" {
  type = map(string)
  default = {
    "UI"        = "enabled"
    "beta"      = "disabled"
    "analytics" = "enabled"
  }
}

resource "local_file" "feature_toggle_files" {
  for_each = var.feature_toggles

  filename = "feature-${each.key}.txt"
  content  = "Feature ${each.key} is ${each.value}"
}

output "feature_toggle_files_output" {
  value = <<-EOT
    ${join("\n", [for local_file in local_file.feature_toggle_files : local_file.content])}
  EOT
}

