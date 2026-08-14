variable "name_prefix" {
  description = "Short prefix for RDS / DynamoDB / secret names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for RDS."
  type        = list(string)
}

variable "node_security_group_id" {
  description = "EKS node security group allowed to reach RDS."
  type        = string
}

variable "mysql_engine_version" {
  description = "RDS MySQL engine version."
  type        = string
}

variable "postgres_engine_version" {
  description = "RDS PostgreSQL engine version."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class. Keep this as small as the exam allows."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
}

variable "backup_retention_days" {
  description = "Automated backup retention. Must be > 0 for the resilience bonus."
  type        = number
}

variable "dynamodb_table_name" {
  description = "DynamoDB table used by the carts service."
  type        = string
}

variable "tags" {
  description = "Extra tags."
  type        = map(string)
  default     = {}
}
