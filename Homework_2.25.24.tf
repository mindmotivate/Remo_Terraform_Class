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



# use for_each to iterate over the regions and create a local_file resource for each. 
# The file should be named indicating the region and include basic content for the alert policy.


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
