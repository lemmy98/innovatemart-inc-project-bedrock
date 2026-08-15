locals {
  # Shared EKS API access for the kubernetes and helm providers.
  eks_host = module.eks.cluster_endpoint
  eks_ca   = base64decode(module.eks.cluster_certificate_authority_data)
  eks_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region,
    ]
  }

  # Helm provider v3 wants an object attribute, not a nested "kubernetes" block.
  helm_kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = local.eks_ca
    exec                   = local.eks_exec
  }
}

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
  kubernetes = local.helm_kubernetes
}
