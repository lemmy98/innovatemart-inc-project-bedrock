# Exam requires exactly these five non-sensitive root outputs.
# Do not add passwords, access keys, or console credentials here.

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region."
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.networking.vpc_id
}

output "assets_bucket_name" {
  description = "Private S3 bucket for product image uploads."
  value       = module.serverless.bucket_name
}
