output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "The public IP address of the Bastion EC2 instance"
}
