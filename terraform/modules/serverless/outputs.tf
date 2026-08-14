output "bucket_name" {
  description = "Assets bucket name."
  value       = aws_s3_bucket.assets.id
}

output "bucket_arn" {
  description = "Assets bucket ARN."
  value       = aws_s3_bucket.assets.arn
}

output "lambda_name" {
  description = "Processor function name."
  value       = aws_lambda_function.processor.function_name
}

output "lambda_arn" {
  description = "Processor function ARN."
  value       = aws_lambda_function.processor.arn
}
