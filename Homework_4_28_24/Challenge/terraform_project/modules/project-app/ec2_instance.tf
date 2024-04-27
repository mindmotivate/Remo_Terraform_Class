resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = "t2.medium"
  tags = {
    Name = "${var.app_region}-app-server"
  }
}

output "ec2_instance_id" {
  value = aws_instance.app_server.id
  depends_on  = [aws_instance.app_server]
}
