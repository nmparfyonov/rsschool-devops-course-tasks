resource "aws_instance" "bastion" {
  ami                         = var.ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  source_dest_check           = false

  user_data = <<-EOF
              #!/bin/bash
              sudo -u ec2-user mkdir -p /home/ec2-user/.kube
              chown ec2-user:ec2-user /home/ec2-user/.kube
              yum install -y iptables-services
              echo 1 > /proc/sys/net/ipv4/ip_forward
              iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
              echo "${var.private_key}" > /root/.ssh/id_rsa
              chmod 400 /root/.ssh/id_rsa
              echo "${var.public_key}" >> /home/ec2-user/.ssh/authorized_keys
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              EOF

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_instance" "k3s-master" {
  ami                         = var.ami
  instance_type               = var.k3s_instance_type
  subnet_id                   = aws_subnet.private_subnet[0].id
  associate_public_ip_address = false
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.private_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              curl -sfL https://get.k3s.io | sh -
              echo "${var.private_key}" > /root/.ssh/id_rsa
              chmod 400 /root/.ssh/id_rsa
              echo "${var.public_key}" >> /home/ec2-user/.ssh/authorized_keys
              scp -o StrictHostKeyChecking=no /etc/rancher/k3s/k3s.yaml ec2-user@${aws_instance.bastion.private_ip}:/home/ec2-user/.kube/config
              sleep 60
              token=$(cat /var/lib/rancher/k3s/server/node-token)
              k3s_master_ip=$(hostname -I | awk '{print $1}')
              ssh -o StrictHostKeyChecking=no ec2-user@${aws_instance.bastion.private_ip} "sed -i "s/127.0.0.1/$k3s_master_ip/g" /home/ec2-user/.kube/config"
              ssh -o StrictHostKeyChecking=no root@${aws_instance.k3s-worker.private_ip} "curl -sfL https://get.k3s.io | K3S_URL=https://$k3s_master_ip:6443 K3S_TOKEN=$token sh -"
              EOF

  tags = {
    Name = "k3s-master"
  }
}

resource "aws_instance" "k3s-worker" {
  ami                         = var.ami
  instance_type               = var.k3s_instance_type
  subnet_id                   = aws_subnet.private_subnet[0].id
  associate_public_ip_address = false
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.private_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "${var.public_key}" > /root/.ssh/authorized_keys
              EOF

  tags = {
    Name = "k3s-worker"
  }
}
