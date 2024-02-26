variable "node_config" {
  description = "Configuration settings for the server."
  type = tuple([
    string, // hostname
    number, // ip_address
    bool, // operating_system
    string, // operating_system
  ])
  default = ["node01", 8, false, "worker"]
}


resource "local_file" "node_info" {
  filename = "${path.module}/server-config-summary.txt"
  content = <<-EOT
  Node Name: ${var.server_config[0]}
  CPU Cores: ${var.server_config[1]}
  Master Nodes: ${var.server_config[2]} ? "Yes" : "No"}
  Role: ${var.server_config.is_activ3[3]}
  EOT
}

*/



/*


resource "local_file" "static_server_info" {
  filename = "${path.module}/static-server-info.txt"
  content  = "Hostname: ${var.server_config[0]}, IP Address: ${var.server_config[1]}, Operating System: ${var.server_config[2]}"
}







variable "node_config" {
  description = "Configuration settings for the server."
  type = tuple([
    string, // hostname
    number, // ip_address
    bool,   // is_master
    string, // role
  ])
  default = ["node01", 8, false, "worker"]
}

resource "local_file" "node_info" {
  count = length(var.node_config)

  filename = "${path.module}/node-${count.index}-info.txt"
  content = <<-EOT
    Node Name: ${var.node_config[count.index][0]}
    CPU Cores: ${var.node_config[count.index][1]}
    Master Node: ${var.node_config[count.index][2] ? "Yes" : "No"}
    Role: ${var.node_config[count.index][3]}
  EOT
}
*/



variable "node_config" {
  description = "Number of server configurations."
  type        = number
  default     = 3
}

resource "local_file" "node_config" {
  count = var.node_config

  filename = "${path.module}/node-${count.index}-config.txt"
  content  = "This is configuration for node ${count.index}."
}
