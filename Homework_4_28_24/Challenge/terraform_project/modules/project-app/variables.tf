variable "app_region" {
  type        = string
  description = "The AWS region where the resources will be deployed."
}

variable "bucket" {
  type    = string
  default = "project_data"
}

variable "ami" {
  type        = string
  description = "The ID of the AMI to use for the EC2 instance."
}

