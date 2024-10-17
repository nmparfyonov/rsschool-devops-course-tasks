resource "aws_instance" "bastion" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  security_groups             = [aws_security_group.public_sg.id]
  tags = {
    Name = "Bastion Host"
  }
}
