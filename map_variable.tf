# variable

variable "app_settings" {
  description = "Configuration setting for the application."
  type        = map(string)
  default     = {
    "environment" = "production"
    "debug_mode" = "false"
    "version" = "1.0.0"
  }
}


#  static


resource "local_file" "feature_flag_signup_enabled" {
  filename = "${path.module}/signup-enabled.txt"
  content  = "Signup feature is enabled: ${var.feature_flags["signup_enabled"]}"
}

# iteration (use.each.key)

resource "local_file" "feature_flags" {
  for_each = var.feature_flags

  filename = "${path.module}/app-config-${each.key}.txt"
  content  = "${each.key}: ${each.value}"
}
