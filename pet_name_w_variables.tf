# Take each argument from this resouce block and create a "Variable"
/*
resource "local_file" "my-pet" {
  filename = "${path.module}/pet-name.txt"
  content  = "My pet is not called Keisha!!"
}

resource "random_pet" "other-pet" {
  prefix    = "Mr"
  separator = "."
  length    = 1
}
*/

variable "filename2" {
  description = "The filename for the pet name file"
  type        = string
  default     = "pet-name.txt"
}
variable "content2" {
  description = "The content to put in the pet name file"
  type        = string
  default     = "My pet is not called Keisha!"
}
 variable "prefix2" {
  description = "The prefix for the random pet name"
  type        = string
  default     = "Mr"
}
variable "separator2" {
  description = "The separator for the random pet name"
  type        = string
  default     = "."
}
variable "length2" {
  description = "The length of the random pet name"
  type        = number
  default     = 1
}




resource "local_file" "my-pet2" {
  filename = "${path.module}/${var.filename2}"
  content  = var.content2
}

resource "random_pet" "other-pet2" {
  prefix    = var.prefix2
  separator = var.separator2
  length    = var.length2
}

output "pet_info2" {
  value = "I have a pet named ${random_pet.other-pet2.id} and for the record... ${local_file.my-pet2.content}"
}
