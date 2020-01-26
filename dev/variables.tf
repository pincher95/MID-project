terraform {
  required_version = ">= 0.12.0"
}

variable "aws_region" {
  type = string
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

variable "project_key_path" {
  description = "Path to private project key"
  type = string
  default = "./keys/project.pem"
}

variable "project_public_path" {
  description = "Path to public project key"
  type = string
  default = "./keys/project.pub"
}

variable "public_ec2_count" {
  description = "Default ec2 in public subnet"
  default = 1
}

variable "key_pair" {
  description = "EC2 Key pair names, "
  type = list(string)
  default = ["project"]
  #default = ["project_key", "jenkins_key", "bastion_key"]
}

#----------k8s Variables---------------



#----------Jenkins Variables------------
variable "default_locals" {
  default = "true"
}