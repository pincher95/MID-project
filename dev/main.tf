terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">=2.28.1"
  region  = var.aws_region
}

provider "tls" {
  version = "~> 2.1"
}

terraform {
  backend "s3" {
    bucket = "s3-backend-state"
    key    = "state/mid-project/dev-env/dev-net.tfstate"
    region = "us-east-1"#var.aws_region
  }
}

module "vpc" {
  source            = "../modules/vpc"
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone
  env               = var.environment
  ingress_ports     = var.ingress_ports
}

module "key_pair" {
  source   = "../modules/key-pair"
  key_pair = var.key_pair_names
}

module "bastion" {
  source            = "../modules/bastion"
  availability_zone = var.availability_zone
  ec2_type          = var.ec2_type
  private_key_path  = var.project_key_path
  bootstrap_key     = module.key_pair.bootstrap_key
  public_ec2_count  = var.public_ec2_count
  global_sg         = module.vpc.global_sg
  public_subnet     = module.vpc.public_subnet
}

//module "jenkins" {
//  source          = "../modules/jenkins"
//  jenkis_ec2_type = var.ec2_type
//  jenkis_sg       = module.vpc.jenkins_sg
//  global_sg       = module.vpc.global_sg
//  consul_sg       = module.vpc.consul_sg
//  private_key     = var.project_key_path
//  public_key      = var.project_public_path
//  private_key_pem = module.key_pair.project_private_key
//  bastion_ip      = module.bastion.bastion_public_ip
//  bootstrap_key   = module.key_pair.bootstrap_key
//  private_subnet  = module.vpc.privare_subnet
//  namespace       = var.namespace
//  consul_join_tag_key   = var.consul_join_tag_key
//  consul_join_tag_value = var.consul_join_tag_value
//  instance_profile      = module.consul.instance_profile
//}

//module "nfs" {
//  source          = "../modules/nfs"
//  ec2_type        = var.ec2_type
//  global_sg       = module.vpc.global_sg
//  consul_sg       = module.vpc.consul_sg
//  private_key     = var.project_key_path
//  bastion_ip      = module.bastion.bastion_public_ip
//  bootstrap_key   = module.key_pair.bootstrap_key
//  private_subnet  = module.vpc.privare_subnet
//}

module "k8s" {
  source = "../modules/k8s"
  private_subnet_id = module.vpc.privare_subnet
  public_subnet_id  = module.vpc.public_subnet
  env = var.environment
  tags = ""
  vpc_id = module.vpc.vpc_id
  worker_group_name = ""
  worker_node_type = var.worker_type
  worker_sg = module.vpc.worker_sg
  bootstrap_key = module.key_pair.bootstrap_key
}

//module "consul" {
//  source = "../modules/consul"
//  availability_zone = ""
//  private_subnet_id = module.vpc.privare_subnet
//  consul_join_tag_key = var.consul_join_tag_key
//  consul_join_tag_value = var.consul_join_tag_value
//  consul_server_count = var.consul_servers
//  ec2_type = var.ec2_type
//  namespace = var.namespace
//  bootstrap_key = module.key_pair.bootstrap_key
//  consul_sg = module.vpc.consul_sg
//  global_sg = module.vpc.global_sg
//}
