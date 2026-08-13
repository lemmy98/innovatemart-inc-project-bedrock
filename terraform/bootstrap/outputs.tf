output "state_bucket_name" {
  description = "S3 bucket that stores Terraform state. Pass this to terraform init -backend-config."
  value       = aws_s3_bucket.state.id
}

output "backend_hcl" {
  description = "Copy into terraform/envs/backend.hcl (gitignored)."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.state.id}"
    key          = "tinyuka/prod/terraform.tfstate"
    region       = "${var.aws_region}"
    encrypt      = true
    use_lockfile = true
  EOT
}

output "github_actions_role_arn" {
  description = "Put this value in GitHub secret AWS_ROLE_ARN (OIDC — no access keys)."
  value       = aws_iam_role.github_actions.arn
}
