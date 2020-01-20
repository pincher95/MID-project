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

resource "aws_instance" "public-server" {
  count             = length(var.availability_zone)
  availability_zone = element(var.availability_zone, count.index)
  subnet_id         = element(var.public_subnet, count.index)
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.ec2_type
  vpc_security_group_ids = [var.public_sg]
  key_name               = aws_key_pair.server_key.key_name

  tags = {
    Name = "Public_Server_${count.index}"
  }
}

resource "aws_instance" "private-server" {
  count             = length(var.availability_zone)
  availability_zone = element(var.availability_zone, count.index)
  subnet_id         = element(var.private_subnet, count.index)
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.ec2_type
  vpc_security_group_ids = [var.private_sg]
  key_name          = aws_key_pair.server_key.key_name
  tags = {
    Name = "Private_Server_${count.index}"
  }
}
