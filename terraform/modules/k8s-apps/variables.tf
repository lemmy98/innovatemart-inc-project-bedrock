variable "cluster_name" {
  type = string
}

variable "aws_region" {
  description = "AWS region for the cluster (IRSA / controller context)."
  type        = string
}

variable "app_namespace" {
  type = string
}

variable "chart_version" {
  description = "Pinned retail-store Helm chart version."
  type        = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "catalog_endpoint" {
  type = string
}

variable "catalog_username" {
  type = string
}

variable "catalog_password" {
  type      = string
  sensitive = true
}

variable "orders_endpoint" {
  type = string
}

variable "orders_username" {
  type = string
}

variable "orders_password" {
  type      = string
  sensitive = true
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "enable_network_policies" {
  description = "Install NetworkPolicies in the app namespace (bonus)."
  type        = bool
}

# Unused; kept with a default so editors with a stale module schema stop
# flagging the removed Cluster Autoscaler input as a missing required attribute.
variable "enable_cluster_autoscaler" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
