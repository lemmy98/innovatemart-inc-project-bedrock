variable "cluster_name" {
  description = "EKS cluster name. Exam requires project-bedrock-cluster."
  type        = string
}

variable "cluster_version" {
  description = "Oldest actively-supported Kubernetes version on EKS (standard support)."
  type        = string
}

variable "vpc_id" {
  description = "VPC that hosts the cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the control plane ENIs (public + private is typical)."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets for the managed node group."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes."
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
}

variable "node_min_size" {
  description = "Minimum node count (Cluster Autoscaler floor)."
  type        = number
}

variable "node_max_size" {
  description = "Maximum node count (Cluster Autoscaler ceiling; keep small for cost)."
  type        = number
}

variable "node_disk_size" {
  description = "Root volume size in GiB."
  type        = number
}

variable "install_helm_on_nodes" {
  description = "Install the Helm CLI on nodes at boot via cloud-init."
  type        = bool
}

variable "log_retention_days" {
  description = "CloudWatch retention for control-plane log groups."
  type        = number
}

variable "app_namespace" {
  description = "Namespace the developer view policy is scoped to."
  type        = string
}

variable "developer_principal_arn" {
  description = "IAM user ARN mapped to AmazonEKSViewPolicy."
  type        = string
}

variable "operator_principal_arns" {
  description = "IAM principals (e.g. operator user) with AmazonEKSClusterAdminPolicy for kubectl demos."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags."
  type        = map(string)
  default     = {}
}
