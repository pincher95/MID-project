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
  vpc_security_group_ids = [var.public_sg]
  key_name = var.public_aws_key[0]

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

  tags = {
    Name = "Bastion_Server"
  }
}