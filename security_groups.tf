resource "aws_security_group" "public_sg" {
  name        = "public-security-group"
  description = "Security group for public subnet"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public Security Group"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-security-group"
  description = "Security group for private subnet"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow inbound traffic from public subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.public_subnet_cidrs
  }

  ingress {
    description = "Allow inbound traffic from private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Security Group"
  }
}
