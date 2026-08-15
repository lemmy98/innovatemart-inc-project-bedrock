locals {
  helm_install_script = <<-EOT
    #!/bin/bash
    set -euo pipefail
    if ! command -v helm >/dev/null 2>&1; then
      curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    helm version --short || true
  EOT
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
  cloudwatch_log_group_retention_in_days = var.log_retention_days

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    retail = {
      # Keep short: IAM role name_prefix max is 38 chars.
      name           = "retail"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
      disk_size    = var.node_disk_size

      subnet_ids = var.private_subnet_ids

      labels = {
        workload = "retail"
      }

      tags = merge(var.tags, {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      })

      cloudinit_pre_nodeadm = var.install_helm_on_nodes ? [
        {
          content_type = "text/x-shellscript"
          content      = local.helm_install_script
        }
      ] : []
    }
  }

  access_entries = merge(
    {
      developer = {
        principal_arn = var.developer_principal_arn
        type          = "STANDARD"

        policy_associations = {
          view = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
            access_scope = {
              type       = "namespace"
              namespaces = [var.app_namespace]
            }
          }
        }
      }
    },
    {
      for idx, arn in var.operator_principal_arns :
      "operator-${idx}" => {
        principal_arn = arn
        type          = "STANDARD"

        policy_associations = {
          admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    }
  )

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}
