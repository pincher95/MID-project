terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">=2.28.1"
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "s3-backend-state"
    key    = "state/mid-project/dev-env/dev-net.tfstate"
    region = "us-east-1"#var.aws_region
  }
}

module "vpc" {
  source = "../modules/vpc"
  cidr_block = var.cidr_block
  availability_zone = var.availability_zone
  env = var.environment
}

module "key_pair" {
  source = "../modules/key-pair"
  key_pair = var.key_pair_names
}

module "bastion" {
  source = "../modules/bastion"
  availability_zone = var.availability_zone
  ec2_type = var.ec2_type
  private_key_path = var.project_key_path
  public_aws_key = module.key_pair.aws_key_name
  public_ec2_count = var.public_ec2_count
  public_sg = module.vpc.public_sg
  public_subnet = module.vpc.public_subnet
}

module "jenkins" {
  module_depends_on = [module.key_pair]
  source = "../modules/jenkins"
  jenkis_ec2_type = var.ec2_type
  jenkis_sg = module.vpc.jenkins_sg
  private_sg = module.vpc.private_sg
  private_key = var.project_key_path
  public_key = var.project_public_path
  bastion_ip = module.bastion.bastion_public_ip
  private_key_path = var.project_key_path
  public_aws_key = module.key_pair.aws_key_name
  private_subnet = module.vpc.privare_subnet
}

module "k8s" {
  source = "../modules/k8s"
  private_subnet_id = module.vpc.privare_subnet
  public_subnet_id = module.vpc.public_subnet
  env = var.environment
  tags = ""
  vpc_id = module.vpc.vpc_id
  worker_group_name = ""
  worker_node_type = var.ec2_type
  worker_sg = module.vpc.worker_sg
}
