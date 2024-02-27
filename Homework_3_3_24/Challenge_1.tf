# Challenge 1: Define and Utilize Various Terraform Variable Types

## List Variable Task
# Lists are suitable for managing multiple items of the same type, such as a list of server names. By defining a list variable named server_names, we can easily reference and manage these server names. In this task, we initialize the server_names variable with default values ["server1", "server2", "server3"] and create a local_file resource to generate a file named server-names.txt containing these server names, each on a new line.
# This one is pretty straight forward. You're just adding the three server names to your "default" list

variable "server_names" {
  description = "List of server names."
  type        = list(string)
  default     = ["server1", "server2", "server3"]
}

# We want the output file to be named "server-names.txt" 
resource "local_file" "server_names_file" {
  filename = "server-names.txt"
  content  = join("\n", var.server_names)
}

output "server_names_output" {
  value = local_file.server_names_file.content
}


# Join function: Concatenates elements of a list into a single string, separated by a delimiter.
# join(delimiter, list)

# A 'delimiter' is a character or sequence of characters used to separate each element in the list before joining them into a single string.

# Newline character: Represents a line break in a string. This is our delimiter: \n

#this is whats going on: join("\n", var.server_names) = "server1" + "\n" + "server2" + "\n" + "server3"




## Set Variable Task
# Sets ensure uniqueness, which is useful for managing collections of unique items like deployment regions. By defining a set variable named deployment_regions, we can guarantee that each region is listed only once. In this task, we initialize the deployment_regions variable with default values ["us-east-1", "eu-west-1", "ap-south-1"] and create a local_file resource to output these regions into a file named deployment-regions.txt, with each region on a new line.

variable "deployment_regions" {
  description = "Set of deployment regions."
  type        = set(string)
  default     = ["us-east-1", "eu-west-1", "ap-south-1"]
}

resource "local_file" "deployment_regions_file" {
  filename = "deployment-regions.txt"
  content  = join("\n", var.deployment_regions)
}

## Map Variable Task
# Maps are ideal for storing key-value pairs, making them suitable for configurations like application settings. By defining a map variable named app_configuration, we can easily manage various settings for our application. In this task, we initialize the app_configuration variable with key-value pairs {"environment" = "production", "debug_mode" = "false"} and create a local_file resource to encode these settings into a file named app-config.txt.

variable "app_configuration" {
  description = "Map of application configuration."
  type        = map(string)
  default     = {
    environment = "production"
    debug_mode  = "false"
  }
}

resource "local_file" "app_config_file" {
  filename = "app-config.txt"
  content  = jsonencode(var.app_configuration)
}

## Object Variable Task
# Objects allow us to group related attributes together, providing a structured way to manage detailed information. By defining an object variable named server_details, we can encapsulate attributes like server name and IP address. In this task, we initialize the server_details variable with attributes name = "webserver" and ip = "192.168.1.10" and create a local_file resource to write these details into a file named server-details.txt.

variable "server_details" {
  description = "Details of the server."
  type        = object({
    name = string
    ip   = string
  })
  default = {
    name = "webserver"
    ip   = "192.168.1.10"
  }
}

resource "local_file" "server_details_file" {
  filename = "server-details.txt"
  content  = jsonencode(var.server_details)
}

## Tuple Variable Task
# Tuples are suitable for managing fixed sequences of elements with different types. They provide a structured way to define specifications like node configurations. In this task, we define a tuple variable named node_specifications with default values ["node01", 4, true] representing node name, number of CPU cores, and master status. We then create a local_file resource to output these specifications into a file named node-specifications.txt.

variable "node_specifications" {
  description = "Specifications of the node."
  type        = tuple([string, number, bool])
  default     = ["node01", 4, true]
}

resource "local_file" "node_specs_file" {
  filename = "node-specifications.txt"
  content  = join("\n", var.node_specifications)
}
