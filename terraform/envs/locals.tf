locals {
  student_id_slug = lower(replace(replace(var.student_id, "/", "-"), " ", "-"))
  assets_bucket   = "bedrock-assets-${local.student_id_slug}"
  name_prefix     = "bedrock"

  required_tags = {
    Project     = var.project_tag
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Used by kubernetes + helm providers (after EKS exists).
  eks_host = try(module.eks.cluster_endpoint, "")
  eks_ca   = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  eks_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", var.cluster_name,
      "--region", var.aws_region,
    ]
  }
}
