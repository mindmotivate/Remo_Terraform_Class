/*
Challenge 4: Server Configuration with Outputs
Define an object variable named server_config in variables.tf with attributes: hostname, ip_address, and role. Hint - use appropriate default values.
In main.tf, create a local_file resource named server_info that writes these details into a file named server-details.txt.
Use output blocks to output each attribute of server_config.
*/

variable "server_config" {
  type = object({
    hostname   = string
    ip_address = string
    role       = string
  })

  default = {
    hostname   = "example.com"
    ip_address = "192.168.1.100"
    role       = "web server"
  }
}

resource "local_file" "server_info" {
  filename = "server-details.txt"
  content  = <<-EOT
    Hostname:   ${var.server_config.hostname}
    IP Address: ${var.server_config.ip_address}
    Role:       ${var.server_config.role}
  EOT
}

output "hostname" {
  value = var.server_config.hostname
}

output "ip_address" {
  value = var.server_config.ip_address
}

output "role" {
  value = var.server_config.role
}

output "server_info_combined_block" {
  value = local_file.server_info.content
}
