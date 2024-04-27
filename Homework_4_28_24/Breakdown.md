## Modular Setup
The "modules" parent directory contains a child directory called "project-app" which houses the resources for the project

### project-app resources:
```hcl
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
```

```hcl
resource "aws_s3_bucket" "project_data" {
  bucket = "${var.app_region}-project-data"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.project_data.bucket
  depends_on  = [aws_s3_bucket.project_data]
}
```

```hcl
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
```

## us-east-1 sub-directory:

### providers.tf
```hcl
# Defines provider for us-east-1 region
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### main.tf
```hcl
# Includes ami value and references EC2 instance module
module "project-app" {
  source       = "../modules/project-app"
  app_region   = "us-east-1"
  ami          = "ami-0255aa2d18aaa894e"
  }
```







