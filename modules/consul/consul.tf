# Create the user-data for the Consul server
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

data "template_file" "server" {
  count    = var.consul_server_count
  template = file("../templates/consul.sh.tpl")

  vars = {
    CONSUL_VERSION = "1.6.2"
    CONFIG = <<-EOT
      "bootstrap_expect": 3,
      "node_name": "${var.namespace}-server-${count.index}",
      "retry_join": ["provider=aws tag_key=${var.consul_join_tag_key} tag_value=${var.consul_join_tag_value}"],
      "server": true,
      "dns_config": {
        "enable_truncate": true,
        "only_passing": true
      }
    EOT
  }
}

resource "aws_instance" "consule-server" {
  count             = var.consul_server_count
  availability_zone = var.availability_zone
  subnet_id         = var.private_subnet_id[0]
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.ec2_type
  vpc_security_group_ids = [var.consul_sg]
  key_name               = var.public_aws_key[0]
  iam_instance_profile = aws_iam_instance_profile.consul-join.name
  user_data = element(data.template_file.server.*.rendered, count.index)
  tags = map("Name", "${var.namespace}-server-${count.index}", var.consul_join_tag_key, var.consul_join_tag_value)
}