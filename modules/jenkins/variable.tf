variable "jenkis_sg" {}

variable "jenkis_ec2_type" {}

variable "private_sg" {}

variable "private_key" {}

variable "public_key" {}

variable "bastion_ip" {}

variable "private_key_path" {}

variable "public_aws_key" {}

variable "private_subnet" {}

variable "module_depends_on" {
  type    = any
  default = null
}

variable "namespace" {}

variable "consul_join_tag_key" {}

variable "consul_join_tag_value" {}

variable "instance_profile" {}

variable "consul_client_sg" {}
