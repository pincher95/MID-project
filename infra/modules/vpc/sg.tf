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

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private and Public SG
#######################################
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

}

#K8s worker sg
#######################################
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Jenkins Master Securety Group
#######################################
resource "aws_security_group" "jenkins_master_sg" {
  name = "jenkins_master_sg"
  description = "Allow Jenkins inbound traffic"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2375
    to_port = 2375
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins Master SG"
  }
}

#Consul Securety Group
#######################################
resource "aws_security_group" "consul_sg" {
  name        = "consul_sg"
  description = "Allow consul inbound traffic"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access"
  }

  tags = {
    Name = "Consul SG"
  }
}

#MySQL Securety Group
#######################################
resource "aws_security_group" "MySql_sg" {
  name = "MySQL_sg"
  description = "Allow Access to MySQL"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL"
  }

  tags = {
    Name = "MySQL Server SG"
  }
}

#Global Securety Group
#######################################
resource "aws_security_group" "global_sg" {
  name = "global_sg"
  description = "Global inbound and outbound SG"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Dynamic ingress ports"
    }
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inter VPC traffic security group"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outbound traffic"
  }

  tags = {
    Name = "Global inbound and outbound SG rules"
  }
}