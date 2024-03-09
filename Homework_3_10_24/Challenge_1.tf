/*
Challenge 1: Dynamic Web Server Configuration Files
Task:
Define a variable named web_server_names as a list in your variables.tf file with default values: "webserver1", "webserver2", "webserver3".
In main.tf, dynamically create a text file for each web server using a local_file resource. The files should be named webserver-[NAME].txt, and each file should contain the text Server Name: [NAME].
*/


variable "web_server_names" {
  type    = list(string)
  default = ["webserver1", "webserver2", "webserver3"]
}


resource "local_file" "web_server_files" {
  count = length(var.web_server_names)

  filename = "webserver-${count.index + 1}.txt"
  content  = "Server Name: ${var.web_server_names[count.index]}"
}


output "combined_web_server_files" {
  value = <<-EOT
    ${join("\n", [for local_file in local_file.web_server_files : local_file.content])}
  EOT
}
