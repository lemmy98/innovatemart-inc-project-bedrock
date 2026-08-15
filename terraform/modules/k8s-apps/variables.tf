variable "cluster_name" {
  type = string
}

variable "aws_region" {
  description = "AWS region for the cluster (IRSA / controller context)."
  type        = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "enable_cluster_autoscaler" {
  description = "Install Cluster Autoscaler (bonus 5.3). Node group max_size must be > min_size."
  type        = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Kept so older tfvars/module calls that still pass shop inputs do not break plans.
variable "app_namespace" {
  type    = string
  default = "retail-app"
}

variable "chart_version" {
  type    = string
  default = "1.6.2"
}

variable "catalog_endpoint" {
  type    = string
  default = ""
}

variable "catalog_username" {
  type    = string
  default = ""
}

variable "catalog_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "orders_endpoint" {
  type    = string
  default = ""
}

variable "orders_username" {
  type    = string
  default = ""
}

variable "orders_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "dynamodb_table_name" {
  type    = string
  default = ""
}

variable "enable_network_policies" {
  type    = bool
  default = false
}

variable "ui_hostname" {
  type    = string
  default = ""
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}
