terraform {
  required_version = ">= 0.12.0"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "availability_zone" {
  default = ["us-east-1a", "us-east-1b"]
}

variable vpc_id {
  description = "AWS VPC id"
  default     = "vpc-c17b2abb"
}

variable "cluster_name" {
  description = "Web cluster name"
  default = "web_cluster"
}

variable "cidr_block" {
  description = "CIDR block"
  default = "10.0.0.0/16"
}

variable "environment" {
  description = "Project Environment"
  default     = "dev"
}
#----------Compute Variables------------

variable "ec2_type" {
  default = "t2.micro"
}



#----------k8s Variables---------------
