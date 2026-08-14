variable "bucket_name" {
  description = "Private assets bucket name. Exam: bedrock-assets-<student-id>."
  type        = string
}

variable "lambda_name" {
  description = "Lambda function name. Exam requires bedrock-asset-processor."
  type        = string
}

variable "lambda_source_dir" {
  description = "Directory containing handler.py."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention for the Lambda function."
  type        = number
}

variable "tags" {
  description = "Extra tags."
  type        = map(string)
  default     = {}
}
