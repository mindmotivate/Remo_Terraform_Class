variable "user_roles" {
description = "List of user roles"
type = list(string)
default = ["admin","editor","viewer"]
}


resource "local_file" "user_role_file" {
count =  length(var.user_roles)
filename = "${path.module}user_role-${var.user_roles[count.index]}.txt"
content = "${var.user_roles[count.index]}"
}

output "user_role_file_output" {
value = local_file.user_role_file[*].content
}

output "user_role_file_output1" {
value = local_file.user_role_file[0].content
}
output "user_role_file_output2" {
value = local_file.user_role_file[1].content
}

output "user_role_file_output3" {
value = local_file.user_role_file[2].content
}

output "user_role_file_output4" {
value = [for file in local_file.user_role_file : "${file.filename}: ${file.content}"]
}

