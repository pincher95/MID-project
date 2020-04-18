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

resource "aws_instance" "MYSQL_Server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  key_name        = var.public_aws_key[0]
  subnet_id = var.private_subnet_id
  vpc_security_group_ids = [var.mysql_sg, var.global_sg]
  iam_instance_profile = var.instance_profile

  tags = {
    Name = "MySQL_Server-TerraBuild"
  }

  user_data = file(var.mysql_Server_user_data_script)
}