variable "aws_region" {
  description = "AWS region. Exam requires us-east-1."
  type        = string
}

variable "project_tag" {
  description = "Value for the Project tag. Exam requires tinyuka-2025-capstone."
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod). Used for DynamoDB table prefix only; exam resource names stay exact."
  type        = string
}

variable "student_id" {
  description = "AltSchool student ID. S3 does not allow slashes or spaces, so Terraform sanitizes this for the bucket name."
  type        = string
}

variable "vpc_name" {
  description = "VPC Name tag. Exam requires project-bedrock-vpc."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. Exam requires project-bedrock-cluster."
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace. Exam requires retail-app."
  type        = string
}

variable "developer_user_name" {
  description = "IAM developer user. Exam requires bedrock-dev-view."
  type        = string
}

variable "operator_principal_arns" {
  description = "IAM principals granted AmazonEKSClusterAdminPolicy (local kubectl / demos)."
  type        = list(string)
  default     = []
}

variable "lambda_name" {
  description = "Lambda function name. Exam requires bedrock-asset-processor."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
}

variable "azs" {
  description = "Availability zones (minimum two)."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Exam cost guardrail: one NAT Gateway."
  type        = bool
}

variable "cluster_version" {
  description = "Oldest Kubernetes version in EKS standard support."
  type        = string
}

variable "node_instance_types" {
  description = "Worker node instance types."
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired managed node group size."
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
  description = "Worker node root volume size in GiB."
  type        = number
}

variable "install_helm_on_nodes" {
  description = "Install Helm CLI on worker nodes at boot."
  type        = bool
}

variable "log_retention_days" {
  description = "CloudWatch retention (days) for EKS control-plane and Lambda log groups."
  type        = number
}

variable "mysql_engine_version" {
  description = "RDS MySQL engine version for the catalog database."
  type        = string
}

variable "postgres_engine_version" {
  description = "RDS PostgreSQL engine version for the orders database."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for both the catalog and orders databases (e.g. db.t3.micro)."
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GiB for both the catalog and orders databases."
  type        = number
}

variable "backup_retention_days" {
  description = "RDS backup retention. Must be > 0."
  type        = number
}

variable "chart_version" {
  description = "Pinned retail-store sample app Helm chart version."
  type        = string
}

variable "enable_app_deploy" {
  description = "Install ALB controller, Cluster Autoscaler, and carts IRSA. Shop is applied via k8s-deploy workflow."
  type        = bool
}

variable "enable_network_policies" {
  description = "Whether module.k8s_apps should manage NetworkPolicies (false here — they're applied from k8s/networkpolicies/ instead)."
  type        = bool
}

variable "enable_cluster_autoscaler" {
  description = "Install Cluster Autoscaler in stage 2 (bonus 5.3)."
  type        = bool
}

variable "ui_hostname" {
  description = "Subdomain for the UI ALB (bonus 5.2). Leave empty until ACM is issued."
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the UI hostname. Leave empty until validated."
  type        = string
  default     = ""
}

variable "budget_limit_usd" {
  description = "Monthly AWS Budget limit in USD, scoped to the Project tag."
  type        = number
}

variable "budget_notification_email" {
  description = "Email for the AWS Budget alert."
  type        = string
}

variable "admin_access_cidrs" {
  description = <<-EOT
    CIDR blocks allowed to reach the EKS public API endpoint. Required, must
    be non-empty (an empty list is what makes AWS default to 0.0.0.0/0 — this
    variable exists so that choice is explicit, not accidental).

    Prod/dev tfvars list the workstation public IPv4 plus ["0.0.0.0/0"] so
    GitHub-hosted Actions can still reach the API (runner IPs are dynamic).
    This cluster is IPv4-only — do not add IPv6 CIDRs. IAM/EKS Access
    Entries remain the real authorization boundary. See docs/architecture.md.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.admin_access_cidrs) > 0
    error_message = "Set at least one CIDR — use [\"0.0.0.0/0\"] if you need it open, but do so explicitly rather than leaving this empty."
  }
}

