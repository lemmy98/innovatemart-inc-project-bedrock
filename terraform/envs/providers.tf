provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.required_tags
  }
}

provider "kubernetes" {
  host                   = local.eks_host
  cluster_ca_certificate = local.eks_ca

  exec {
    api_version = local.eks_exec.api_version
    command     = local.eks_exec.command
    args        = local.eks_exec.args
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = local.eks_ca
    exec                   = local.eks_exec
  }
}
