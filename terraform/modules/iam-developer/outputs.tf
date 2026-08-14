output "user_name" {
  description = "IAM user name."
  value       = aws_iam_user.developer.name
}

output "user_arn" {
  description = "IAM user ARN (used by the EKS access entry)."
  value       = aws_iam_user.developer.arn
}

output "access_key_id" {
  description = "Access key ID. Share privately with graders — not a root output."
  value       = aws_iam_access_key.developer.id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key. Share privately with graders — not a root output."
  value       = aws_iam_access_key.developer.secret
  sensitive   = true
}

output "console_password" {
  description = "Initial console password. Share privately; user must reset."
  value       = aws_iam_user_login_profile.developer.password
  sensitive   = true
}
