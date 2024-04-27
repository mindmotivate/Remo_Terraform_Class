resource "aws_s3_bucket" "project_data" {
  bucket = "${var.app_region}-project-data"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.project_data.bucket
  depends_on  = [aws_s3_bucket.project_data]
}
