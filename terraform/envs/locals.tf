locals {
  student_id_slug = lower(replace(replace(var.student_id, "/", "-"), " ", "-"))
  assets_bucket   = "bedrock-assets-${local.student_id_slug}"
  name_prefix     = "bedrock"

  required_tags = {
    Project     = var.project_tag
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
