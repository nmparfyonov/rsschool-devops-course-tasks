variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 Bucket name"
  type        = string
  default     = "my-s3-bucket-nmp"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["192.168.3.0/24", "192.168.4.0/24"]
}

variable "ami" {
  description = "AMI for EC2 instances"
  type        = string
  default     = "ami-08ec94f928cf25a9d"
}

variable "bastion_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "k3s_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "EC2 ssh key name"
  type        = string
  default     = "ssh_key"
}

variable "public_key" {
  description = "Public SSH key"
  type        = string
}

variable "private_key" {
  description = "Private SSH key"
  type        = string
}
