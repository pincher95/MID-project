data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "opsSchool-eks-${random_string.suffix.result}"
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  #TODO Subnet id
  subnets      = concat(var.private_subnet_id, var.public_subnet_id)

  tags = {
    Environment = var.env
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = var.vpc_id

  # TODO Worker group 1
  # One Subnet
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.worker_node_type
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      subnets = var.private_subnet_id
      additional_security_group_ids = [var.worker_sg]
    }

  ]
  write_kubeconfig = true
  config_output_path = "./kubeconfig"
}