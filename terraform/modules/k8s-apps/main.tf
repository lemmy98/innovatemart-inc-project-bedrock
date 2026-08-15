# Platform on EKS: ALB controller only.
# Shop workloads live in k8s/ and are applied by the k8s-deploy workflow (not Helm here).

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.4"
  namespace  = "kube-system"

  atomic          = true
  cleanup_on_fail = true
  timeout         = 300

  values = [yamlencode({
    clusterName  = var.cluster_name
    replicaCount = 1
    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.lb_controller_irsa.iam_role_arn
      }
    }
    resources = {
      requests = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }
  })]
}
