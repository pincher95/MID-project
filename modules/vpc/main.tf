#VPC resource
#########################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    Name = var.env
  }
}

#Web Public Subnet resource
###########################################
resource "aws_subnet" "web-public" {
  count                   = length(var.availability_zone)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.availability_zone, count.index)
  tags = {
    Name = "web-public-${element(var.availability_zone, count.index)}"
  }
}

#DB Private Subnet resource
###########################################
resource "aws_subnet" "db-private" {
  count                   = length(var.availability_zone)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index + length(var.availability_zone))
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.availability_zone, count.index)
  tags = {
    Name = "db-private-${element(var.availability_zone, count.index)}"
  }
}

#Route, NAT and IGW resource
#########################################
#IGW resource
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${var.env}-vpc-igw"
  }
}
#Public Route
resource "aws_route_table" "web-public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public route table"
  }
}
#Outbound route public subnet
resource "aws_route" "web-public" {
  route_table_id         = aws_route_table.web-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
#Associated outbound subnet
resource "aws_route_table_association" "web-public" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.web-public.*.id, count.index)
  route_table_id = aws_route_table.web-public.id
}

#Private Route
resource "aws_route_table" "db-private" {
  count  = length(var.availability_zone)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private route ${element(var.availability_zone, count.index)}"
  }
}
#Outbound route private subnet
resource "aws_route" "db-private" {
  count                  = length(var.availability_zone)
  route_table_id         = element(aws_route_table.db-private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_nat_gateway.main.*.id, count.index)
}
#Associated outbound subnet
resource "aws_route_table_association" "db-private" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.db-private.*.id, count.index)
  route_table_id = element(aws_route_table.db-private.*.id, count.index)
}

#IP for each Availability zone
resource "aws_eip" "nat" {
  count = length(var.availability_zone)
}

#NAT gateway for each Availability zone
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zone)
  subnet_id     = element(aws_subnet.web-public.*.id, count.index)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  tags = {
    Name = "NAT-${element(var.availability_zone, count.index)}"
  }
}

#Public Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
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
#Private and Publci SG
######################################################
#Privat Web Security Group
resource "aws_security_group" "db-sg" {
  name        = "db-sg"
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
