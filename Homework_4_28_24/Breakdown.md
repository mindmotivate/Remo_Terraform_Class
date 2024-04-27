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

## eu-west-1 sub-directory:

### providers.tf
```hcl
# Defines the provider for eu-west-1 region
provider "aws" {
  region = "eu-west-1"
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
# References the EC2 instance module for eu-west-1 region
module "ec2_instance_eu_west_1" {
  source       = "../modules/ec2_instance"
  app_region   = "eu-west-1"
  ami          = "ami-0d421d8481" # Replace this with the appropriate AMI ID for eu-west-1 as needed
}
```

### Terminal Outputs:
The terminal will display the following outputs upon resource creation:
```bash
module.project-app.aws_s3_bucket.project_data: [id=us-east-1-project-data]
module.project-app.aws_dynamodb_table.project_db: [id=us-east-1-table]
module.project-app.aws_instance.app_server: [id=i-0ce955d84cb81b7a8]
```
![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/3d816e8a-c4e0-4b49-8946-e3398f687699)

Optionally, another set of output resources can be used:
### outputs.tf
```hcl
output "dynamodb_table_name" {
  value = module.project-app.dynamodb_table_name
}

output "s3_bucket_name" {
  value = module.project-app.s3_bucket_name
}

output "ec2_instance_id" {
  value = module.project-app.ec2_instance_id
}
```

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/d8c9d826-0cf1-4c82-996f-fcb9da3bbc05)


### Console Results

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/966de9d9-6c6b-430f-a84e-369c088d2ad2)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/4ec4b919-502c-48c7-a35b-b98efef10b28)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/b625630c-db63-46a3-9144-902e2bc5da2e)

