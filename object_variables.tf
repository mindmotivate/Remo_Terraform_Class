
# object variable
variable "server_config" {
  description = "Configuration settings for the application."
  type = object({
    hostname  = string
    ip_address   = string
    operating_system  = string
    is_active = bool
    installed_services = list(string)
  })
  default = {
    hostname  = "server-01"
    ip_address   = "192.168.1.10"
    operating_system  = "Unbuntu"
    is_active = true
    installed_services = ["nginx", "mysql"]
  }
}


resource "local_file" "server_info" {
  filename = "${path.module}/server-config-summary.txt"
  content = <<-EOT
  Hostname: ${var.server_config.hostname}
  IP Address: ${var.server_config.ip_address}
  Operating System: ${var.server_config.operating_system}
  Active: ${var.server_config.is_active ? "Yes" : "No"}
  Installed Services: ${join(", ", var.server_config.installed_services)}
  EOT
}



resource "local_file" "static_server_info" {
  filename = "${path.module}/static-server-info.txt"
  content  = "Hostname: ${var.server_config.hostname}, IP Address: ${var.server_config.ip_address}, Operating System: ${var.server_config.operating_system}"
}

/*
resource "local_file" "server_info" {
  for_each = var.server_config

  filename = "${path.module}/server-${each.key}.txt"
  content  = "Server ${each.key}: ${each.value}"
}
*/


output "hostname" {
  description = "Hostname of the server."
  value       = var.server_config.hostname
}


output "ip_address" {
  description = "IP address of the server."
  value       = var.server_config.ip_address
}

output "operating_system" {
  description = "Operating system of the server."
  value       = var.server_config.operating_system
}

output "is_active" {
  description = "Indicates if the server is active or not."
  value       = var.server_config.is_active
}

output "installed_services" {
  description = "List of installed services on the server."
  value       = var.server_config.installed_services
}

/*
output "server_config_summary" {
  description = "Summary of server configuration."
  value = <<-EOT
    Hostname: ${var.server_config.hostname}
    IP Address: ${var.server_config.ip_address}
    Operating System: ${var.server_config.operating_system}
    Active: ${var.server_config.is_active ? "Yes" : "No"}
    Installed Services: ${join(", ", var.server_config.installed_services)}
  EOT
}
*/

output "server_config_summary" {
  description = "Summary of server configuration."
  value = <<-EOT
    Hostname: ${var.server_config.hostname}
    IP Address: <a href="http://${var.server_config.ip_address}">a>
    Operating System: ${var.server_config.operating_system}
    Active: ${var.server_config.is_active ? "Yes" : "No"}
    Installed Services: ${join(", ", var.server_config.installed_services)}
  EOT
}
