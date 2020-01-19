#EC2, SG and Key-Pair resources
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

resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "server_key" {
  key_name   = "server_key"
  public_key = tls_private_key.server_key.public_key_openssh
}

resource "local_file" "server_key" {
  sensitive_content = tls_private_key.server_key.private_key_pem
  filename = "demo.pem"
}

resource "aws_instance" "web-server" {
  count             = length(var.availability_zone)
  availability_zone = element(var.availability_zone, count.index)
  subnet_id         = element(var.public_subnet, count.index)
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.ec2_type
  vpc_security_group_ids = [var.public_sg]
  key_name               = aws_key_pair.server_key.key_name

  tags = {
    Name = "Web_Server_${count.index}"
  }
}

resource "aws_instance" "db-server" {
  count             = length(var.availability_zone)
  availability_zone = element(var.availability_zone, count.index)
  subnet_id         = element(var.private_subnet, count.index)
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.ec2_type
  vpc_security_group_ids = [var.private_sg]
  key_name          = aws_key_pair.server_key.key_name
  tags = {
    Name = "DB_Server_${count.index}"
  }
}