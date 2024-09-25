terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "s3_example" {
  bucket = var.s3_bucket_name
  tags = {
    Name        = "My S3 Bucket"
    Environment = var.environment
  }
}
