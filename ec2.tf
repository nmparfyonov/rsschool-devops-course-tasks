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
              sudo -u ${var.ami_username} mkdir -p /home/${var.ami_username}/.kube
              chown ${var.ami_username}:${var.ami_username} /home/${var.ami_username}/.kube
              yum install -y iptables-services
              echo 1 > /proc/sys/net/ipv4/ip_forward
              iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
              echo "${var.private_key}" > /root/.ssh/id_rsa
              chmod 400 /root/.ssh/id_rsa
              echo "${var.public_key}" >> /home/${var.ami_username}/.ssh/authorized_keys
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              kubectl completion bash > /etc/bash_completion.d/kubectl
              curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
              chmod 700 get_helm.sh
              ./get_helm.sh
              helm completion bash > /etc/bash_completion.d/helm
              dnf install -y nginx
              systemctl enable nginx.service
              systemctl start nginx.service
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
              echo "${var.public_key}" >> /home/${var.ami_username}/.ssh/authorized_keys
              scp -o StrictHostKeyChecking=no /etc/rancher/k3s/k3s.yaml ${var.ami_username}@${aws_instance.bastion.private_ip}:/home/${var.ami_username}/.kube/config
              sleep 60
              token=$(cat /var/lib/rancher/k3s/server/node-token)
              k3s_master_ip=$(hostname -I | awk '{print $1}')
              ssh -o StrictHostKeyChecking=no ${var.ami_username}@${aws_instance.bastion.private_ip} "sed -i "s/127.0.0.1/$k3s_master_ip/g" /home/${var.ami_username}/.kube/config"
              ssh -o StrictHostKeyChecking=no root@${aws_instance.k3s-worker.private_ip} "curl -sfL https://get.k3s.io | K3S_URL=https://$k3s_master_ip:6443 K3S_TOKEN=$token sh -"
              dnf install -y iscsi-initiator-utils
              systemctl start iscsid.service
              ssh -o StrictHostKeyChecking=no ${var.ami_username}@${aws_instance.bastion.private_ip} "echo "$k3s_master_ip master.k3s" | sudo tee -a /etc/hosts"
              ssh -o StrictHostKeyChecking=no ${var.ami_username}@${aws_instance.bastion.private_ip} "echo "${aws_instance.k3s-worker.private_ip} worker.k3s" | sudo tee -a /etc/hosts"
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
              dnf install -y iscsi-initiator-utils
              systemctl start iscsid.service
              EOF

  tags = {
    Name = "k3s-worker"
  }
}
