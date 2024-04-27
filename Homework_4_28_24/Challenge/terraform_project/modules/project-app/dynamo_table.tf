resource "aws_dynamodb_table" "project_db" {
  name         = "${var.app_region}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "EmployeeID"

  attribute {
    name = "EmployeeID"
    type = "N"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.project_db.name
  depends_on  = [aws_dynamodb_table.project_db]
}
