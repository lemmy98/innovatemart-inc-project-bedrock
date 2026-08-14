variable "user_name" {
  description = "IAM user name. Exam requires bedrock-dev-view."
  type        = string
}

variable "assets_bucket_arn" {
  description = "ARN of the private assets bucket (for s3:PutObject)."
  type        = string
}

variable "tags" {
  description = "Extra tags."
  type        = map(string)
  default     = {}
}
