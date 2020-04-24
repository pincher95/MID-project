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

provider "helm" {
  version = "~>1.1"
  kubernetes {
    config_path = "./kubeconfig"
  }
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

module "k8s" {
  source = "../modules/k8s"
  private_subnet_id = module.vpc.privare_subnet
  public_subnet_id  = module.vpc.public_subnet
  global_sg         = module.vpc.global_sg
  env = var.environment
  tags = ""
  vpc_id = module.vpc.vpc_id
  worker_group_name = ""
  worker_node_type = var.worker_type
  bootstrap_key = module.key_pair.bootstrap_key
  namespaces = var.namespaces
}