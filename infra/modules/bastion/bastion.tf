#EC2 Bastion
####################################
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  count = var.public_ec2_count
  availability_zone = element(var.availability_zone, count.index)
  subnet_id = element(var.public_subnet, count.index)
  ami = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  vpc_security_group_ids = [var.global_sg]
  key_name = var.bootstrap_key[0]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source = var.private_key_path
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0400 ~/.ssh/id_rsa"
    ]
  }

  tags = {
    Name = "Bastion Server"
  }
}

resource "local_file" "ssh" {
  count = var.public_ec2_count
  content     = <<-EOT
    Host *
      User ubuntu
      IdentityFile ../keys/project.pem
      ProxyCommand ssh -W %h:%p ubuntu@${aws_instance.bastion[0].public_ip}

    Host ${aws_instance.bastion[0].public_ip}
      Hostname ${aws_instance.bastion[0].public_ip}
      User ubuntu
      IdentityFile ..keys/project.pem
      ForwardAgent yes
  EOT
  filename = "../ansible/ssh.cfg"

  depends_on = [aws_instance.bastion]
}