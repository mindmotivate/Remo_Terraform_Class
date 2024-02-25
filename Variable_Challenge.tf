
#Challenge

# Define Variables:
# In a file named variables.tf, define two variables:
# A list variable named server_roles with the default values of "web", "application", "database".

# Example Variables.tf file

variable "server_roles" {
description = "Defined list of server roles"
type = list(string)
default = ["web", "application", "database"]
}

variable "server_regions" {
description = "Defined set of server_regions"
type = set(string)
default = ["us-east-1", "us-west-1", "eu-central-1"]
}

# Define Resources:
# A set variable named server_regions with the default values of "us-east-1", "us-west-1", "eu-central-1". 
# Ensure each variable includes a description and the correct type.

resource "local_file" "server_role_file" {
  filename = "${path.module}/server-role-${var.server_roles[0]}.txt"
  content  = "The first server role is ${var.server_roles[0]}"
}


resource "local_file" "server_region_file" {
  filename = "${path.module}/server-region.txt"
  content  = "The server region is ${tolist(var.server_regions)[2]}"
}

output  "The_First_Server_Role" {
value = "The first server role is: ${var.server_roles[0]}"
}

output  "The_First_Server_Region" {
value = "The first server region is: ${tolist(var.server_regions)[2]}"
}
