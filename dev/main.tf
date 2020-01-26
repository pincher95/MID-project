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

module "compute" {
  source = "../modules/compute"
  ec2_type = var.ec2_type
  private_subnet = module.vpc.privare_subnet
  public_subnet = module.vpc.public_subnet
  private_sg = module.vpc.private_sg
  public_sg = module.vpc.public_sg
  availability_zone = var.availability_zone
  key_pair = var.key_pair
  public_ec2_count = var.public_ec2_count
  private_key_path = var.project_key_path
  bastion_ip = ""
  depend_on = ""
  jenkis_ec2_type = var.ec2_type
  jenkis_sg = module.vpc.jenkins_sg
  private_key = ""
}

module "jenkins" {
  source = "../modules/jenkins"
  jenkis_ec2_type = var.ec2_type
  jenkis_sg = module.vpc.jenkins_sg
  private_key = var.project_key_path
  bastion_ip = module.compute.public_ip
  private_key_path = var.project_key_path
  #dependency = module.compute.local_private
  depend_on = module.compute.local_private
}

//module "k8s" {
//  source = "../modules/k8s"
//  subnet_id = module.vpc.privare_subnet
//  env = var.environment
//  tags = ""
//  vpc_id = module.vpc.vpc_id
//  worker_group_name = ""
//  worker_node_type = var.ec2_type
//  worker_sg = module.vpc.worker_sg
//}
