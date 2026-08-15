# Bonus 5.3 — Cluster Autoscaler. Off when enable_cluster_autoscaler is false.

module "cluster_autoscaler_irsa" {
  count   = var.enable_cluster_autoscaler ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.55"

  role_name                        = "${var.cluster_name}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = var.tags
}

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.53.0"
  namespace  = "kube-system"

  atomic          = true
  cleanup_on_fail = true
  timeout         = 300

  # Chart 9.53.0 + image v1.34.2 matches EKS 1.34 (CA minor == cluster minor).
  values = [yamlencode({
    autoDiscovery = {
      clusterName = var.cluster_name
    }
    awsRegion    = var.aws_region
    replicaCount = 1
    rbac = {
      serviceAccount = {
        create = true
        name   = "cluster-autoscaler"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.cluster_autoscaler_irsa[0].iam_role_arn
        }
      }
    }
    extraArgs = {
      expander                        = "least-waste"
      "balance-similar-node-groups"   = true
      "skip-nodes-with-system-pods"   = false
      "skip-nodes-with-local-storage" = true
    }
    image = {
      tag = "v1.34.2"
    }
    resources = {
      requests = {
        cpu    = "50m"
        memory = "128Mi"
      }
      limits = {
        memory = "256Mi"
      }
    }
  })]

  depends_on = [helm_release.aws_load_balancer_controller]
}
