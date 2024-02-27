
# **Terraform List Variable Example 1**

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
