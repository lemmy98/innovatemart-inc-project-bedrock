output "carts_irsa_role_arn" {
  description = "IAM role ARN for carts ServiceAccount (IRSA). Annotated by scripts/k8s-sync-secrets.sh."
  value       = module.carts_irsa.iam_role_arn
}

output "lb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller."
  value       = module.lb_controller_irsa.iam_role_arn
}
