# Challenge 1

# Variables
# Define a variable in variables.tf to hold the list of server roles.
#N Notice how all of the "list" items are in brackets
variable "the_server_roles" {
  description = "List of server roles requiring monitoring."
  type        = list(string)
  default     = ["cache", "queue", "worker"]
}

output  "The_server_roles" {
description = "The server role are as follows:"
value = var.the_server_roles
}

# Resources
# Create local_file resources in main.tf using for_each to generate a separate monitoring 
# configuration file for each server role. Name the files based on the server role and 
# provide some generic monitoring settings in the content.
resource "local_file" "monitoring_config" {
  for_each = toset(var.server_roles)
  filename = "${path.module}/monitoring-${each.key}.conf"
  content  = "Generic monitoring settings for ${each.key} server."
}

output  "monitoring_config" {
value = { for key, config in local_file.monitoring_config : key => config.content }
}


# Challenge 2
# Define a variable in variables.tf to hold the set of deployment regions.
variable "deployment_regions" {
  description = "Set of deployment regions."
  type        = set(string)
  default     = ["eu-north-1", "ap-south-1", "me-south-1"]
}

output  "The_Deployment_regions" {
description = "The deployment regions are as follows:"
value = var.deployment_regions
}

# Define the local_file resources for each deployment region
resource "local_file" "alert_policy" {
  for_each = var.deployment_regions

  filename = "${path.module}/${each.key}_alert_policy.txt"
  content  = "Alert policy for ${each.key} region."
}

# Output to display the created local files
output "created_files" {
  description = "List of created local files for alert policies."
  value       = {
    for key, file in local_file.alert_policy : key => file.filename
  }
}


# Challenge 3

# Define the following Variables:

# A list variable named network_zones with the default values of "public", "private", "protected". 
# Include a description for this variable.
# A set variable named operating_systems with the default values of "linux", "windows", "macos". 
# Ensure each variable includes a description.

# Variables
variable "network_zones" {
  description = "List of network zones."
  type        = list(string)
  default     = ["public", "private", "protected"]
}

variable "operating_systems" {
  description = "Set of operating systems."
  type        = set(string)
  default     = ["linux", "windows", "macos"]
}

#Create two `local_file` resources:
#`network_zone_file`: Generate a file named `zone-type-[FIRST_ZONE].txt` using the first item in the `network_zones` list.
# The content should be "Network zone type: [FIRST_ZONE]".
#`operating_system_file`: Generate a file named `os-info.txt` using the first item in the `operating_systems` set. 
# Convert the set to a list, then reference the first item. The content should be "Operating system in use: [FIRST_OS]".


# Resources
resource "local_file" "network_zone_file" {
  filename = "${path.module}/zone-type-${var.network_zones[0]}.txt"
  content  = "Network zone type: ${var.network_zones[0]}"
}

resource "local_file" "operating_system_file" {
  filename = "${path.module}/os-info.txt"
  content  = "Operating system in use: ${tolist(var.operating_systems)[0]}"
}


# Outputs
output "network_zone_file_content" {
  value = local_file.network_zone_file.content
}

output "operating_system_file_content" {
  value = local_file.operating_system_file.content
}
