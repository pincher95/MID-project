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
  subnets      = ["subnet-0572a748", "subnet-18b1b744", "subnet-8b3035ec", "subnet-984a49b6"]

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = "vpc-c17b2abb"

  # TODO Worker group 1
  # One Subnet
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      # TODO Subnet
      #additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }

  ]

}