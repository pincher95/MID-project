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

resource "aws_instance" "bastion-server" {
  count = var.public_ec2_count
  availability_zone = element(var.availability_zone, count.index)
  subnet_id = element(var.public_subnet, count.index)
  ami = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  vpc_security_group_ids = [var.public_sg]
  key_name = aws_key_pair.server_key[0].key_name

  depends_on = [local_file.server_key_private]

  //  ssh keys
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
      "sudo echo -e '\tStrictHostKeyChecking no' >> /etc/ssh/ssh_config"
    ]
  }

  tags = {
    Name = "Bastion_Server"
  }
}