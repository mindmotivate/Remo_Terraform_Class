
# **Terraform Variable Example 1**

**Imagine you have three types of server roles that require monitoring: a cache server, a queue server, and a worker server (default values). Each server role needs a unique monitoring configuration file.**

**Task:**
**Define a variable in variables.tf to hold the list of server roles.**


### ***Define a variable in variables.tf to hold the list of server roles.***
variable "server_roles" {
  ### ***List of different server roles to set up monitoring for.***
  description = "List of different server roles to set up monitoring for."
  
  ### ***Specify the type as list of strings.***
  type        = list(string)
  
  ### ***Set default values for the server roles (cache, queue, worker).***
  default     = ["cache", "queue", "worker"]
}


## ***Here's what your variable should look like:***

hcl
```
variable "server_roles" {
  description = "List of different server roles to set up monitoring for."
  type        = list(string)
  default     = ["cache", "queue", "worker"]
}
```
***A string is a data type used to represent text. It consists of a sequence of characters, which can include letters, numbers, symbols, and spaces.***



<hr style="width: 80%; height: 10px; background-color: black;">


<>
# **Terraform Variable Example 2**

**Your infrastructure is deployed in three different regions: Europe North (eu-north-1), Asia Pacific South (ap-south-1), and Middle East South (me-south-1) (default values). You need to create an alert policy file for each region.**

**Task:**
**Define a variable in variables.tf to hold the set of deployment regions.***



### ***Define a variable in variables.tf to hold the set of deployment regions.***
variable "deployment_regions" {
  
### ***Description: Set of deployment regions for the infrastructure.***
description = "Set of deployment regions for the infrastructure."
  
### ***Type: List of strings.***
type        = list(string)
  
### ***Default Values: Europe North (eu-north-1), Asia Pacific South (ap-south-1), and Middle East South (me-south-1).***
default     = ["eu-north-1", "ap-south-1", "me-south-1"]
}


## ***Here's what your variable should look like:***
hcl
```
variable "deployment_regions" {
  description = "Set of regions to create alert policies for."
  type        = set(string)
  default     = ["eu-north-1", "ap-south-1", "me-south-1"]
}
```

