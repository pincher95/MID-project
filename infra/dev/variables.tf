variable "aws_region" {
  type = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "availability_zone" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
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

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}
#----------Compute Variables------------

variable "ec2_type" {
  default = "t2.micro"
}

variable "public_ec2_count" {
  description = "Default ec2 in public subnet"
  default = 1
}
#----------key-pair--------------------
variable "project_key_path" {
  description = "Path to private project key"
  type = string
  default = "../keys/project.pem"
}

variable "project_public_path" {
  description = "Path to public project key"
  type = string
  default = "../keys/project.pub"
}

variable "key_pair_names" {
  description = "EC2 Key pair names, "
  type = list(string)
  default = ["project"]
  #default = ["project_key", "jenkins_key", "bastion_key"]
}

#----------k8s Variables---------------

variable "worker_type" {
  default = "t2.medium"
}

variable "namespaces" {
  type = list(string)
  default = ["kube-consul", "kube-metrics", "kube-logging", "kube-jenkins", "kube-app"]
}
#----------Jenkins Variables------------
variable "default_locals" {
  default = "true"
}

variable "jenkins_cred_path" {
  description = "Jenkins credentials xml"
  type = string
  default = "./templates/credentials.xml.tpl"
}

#-----------Consul Variables----------------
variable "consul_servers" {
  default = 3
}

variable "namespace" {
  default = "consul"
}

variable "consul_join_tag_key" {
  description = "The key of the tag to auto-jon on EC2."
  default     = "consul_join"
}

variable "consul_join_tag_value" {
  description = "The value of the tag to auto-join on EC2."
  default     = "dev"
}
