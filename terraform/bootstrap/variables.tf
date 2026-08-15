variable "aws_region" {
  description = "AWS region for the remote-state bucket."
  type        = string
}

variable "project_tag" {
  description = "Value of the Project tag applied to the state bucket."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name that will hold Terraform state."
  type        = string
}

variable "github_repository" {
  description = "GitHub org/repo allowed to assume the CI OIDC role (e.g. lemmy98/innovatemart-inc-project-bedrock)."
  type        = string
}

variable "github_owner_id" {
  description = "Numeric GitHub owner/org ID for immutable OIDC sub claims (gh api ... --jq .owner.id)."
  type        = string
}

variable "github_repository_id" {
  description = "Numeric GitHub repository ID for immutable OIDC sub claims (gh api ... --jq .id)."
  type        = string
}
