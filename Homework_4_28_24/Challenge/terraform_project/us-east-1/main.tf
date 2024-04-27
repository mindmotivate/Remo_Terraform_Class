module "project-app" {
  source       = "../../modules/project-app"
  app_region   = "us-east-1"
  ami          = "ami-0255aa2d18aaa894e"
}
