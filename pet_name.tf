#Create a new configuration file called pet-name.tf.
#This file should make use of the local_file and random_pet resourc

#Important!
#You don't need to specify a filename and content because this resource is not creating a file 
# The random_pet resource generates a random string based on the provided parameters 
# (prefix, separator, and length) are used in our example



resource "local_file" "my-pet" {
  filename = "${path.module}/pet-name.txt"
  content  = "My pet is not called Keisha!!"
}

resource "random_pet" "other-pet" {
  prefix    = "Mr"
  separator = "."
  length    = 1
}

output "pet_name" {
  value = "${random_pet.other-pet.id}"
  } 

output "pet_info" {
  value = "I have a pet named ${random_pet.other-pet.id} ${local_file.my-pet.content} and for the record... ${local_file.my-pet.content}"
}
