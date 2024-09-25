resource "aws_s3_bucket" "s3_example" {
  bucket = var.s3_bucket_name
  tags = {
    Name        = "My S3 Bucket"
    Environment = var.environment
  }
}
