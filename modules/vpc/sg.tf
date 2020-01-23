#Public Security Group
#################################
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "security group for web servers"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Private and Public SG
######################################################
#Privat Web Security Group
resource "aws_security_group" "private-sg" {
  name        = "private-sg"
  description = "security group for db servers"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#k8s worker sg
#################################
# CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "209.88.185.5/32",
      "207.232.13.77/32",
      "192.168.1.0/32",
      "89.138.10.68/32"
    ]
  }
  ingress {
    from_port = 30017
    to_port     = 30017
    protocol    = "tcp"
  }
}