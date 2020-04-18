terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">=2.28.1"
  region  = var.aws_region
}

provider "helm" {
  version = "~>1.1"
  kubernetes {
    config_path = "../${path.root}/kubeconfig"
  }
}

module "helm" {
  source = "./modules/helm"
}