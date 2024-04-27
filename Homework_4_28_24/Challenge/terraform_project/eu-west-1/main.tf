module "ec2_instance_eu_west_1" {
  source       = "../../modules/ec2_instance"
  app_region   = "eu-west-1"
  ami          = "ami-0d421d8481" 
}
