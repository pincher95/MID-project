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

#IGW resource
#########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${var.env}-vpc-igw"
  }
}

#Public Subnet resource
##########################################
resource "aws_subnet" "public" {
  count                   = length(var.availability_zone)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 7, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.availability_zone, count.index)
  tags = {
    Name = "public-${element(var.availability_zone, count.index)}"
    kubernetes.io/role/elb = 1
  }
}

#Private Subnet resource
###########################################
resource "aws_subnet" "private" {
  count                   = length(var.availability_zone)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 7, count.index + length(var.availability_zone))
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.availability_zone, count.index)
  tags = {
    Name = "private-${element(var.availability_zone, count.index)}"
    kubernetes.io/role/internal-elb = 1
  }
}