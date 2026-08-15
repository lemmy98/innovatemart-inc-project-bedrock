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
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_disk_size" {
  type = number
}

variable "install_helm_on_nodes" {
  description = "Install Helm CLI on worker nodes at boot."
  type        = bool
}

variable "log_retention_days" {
  type = number
}

variable "mysql_engine_version" {
  type = string
}

variable "postgres_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
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
  type = bool
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
  type = number
}

variable "budget_notification_email" {
  description = "Email for the AWS Budget alert."
  type        = string
}

