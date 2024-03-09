/*
Challenge 3: Explicit Dependency Creation
Create two resources in main.tf: resource_a and resource_b, both of type local_file.
resource_a should generate a file named a.txt with any content.
resource_b should generate a file named b.txt with any content and should explicitly depend on resource_a without using a direct reference in its properties, i.e. use explicit dependency.
*/


resource "local_file" "resource_a" {
  filename = "a.txt"
  content  = "Content of A"
}

resource "local_file" "resource_b" {
  filename = "b.txt"
  content  = "Content of B"
  depends_on = [local_file.resource_a]
}

output "content_a_output" {
value = local_file.resource_a.content
}

output "content_b_output" {
value = local_file.resource_b.content
}




#Implicit vs. Explicit Dependency Creation example using random id generator

resource "random_id" "random_a1" {
  byte_length = 8
}

resource "local_file" "resource_a1" {
  filename = "a.txt"
  content  = random_id.random_a1.hex
}

resource "random_id" "random_b1" {
  byte_length = 8
}

resource "local_file" "resource_b1" {
  filename   = "b.txt"
  content    = random_id.random_b1.hex
  depends_on = [local_file.resource_a]
}

output "content_a_random_output" {
  value = local_file.resource_a1.content
}

output "content_b_random_output" {
  value = local_file.resource_b1.content
}


