# Exam requirements stated below, grading values.

aws_region  = "us-east-1"
project_tag = "Project:tinyuka-2025-capstone"
environment = "prod"
student_id  = "alt/soe/tin/025/0021"

vpc_name            = "project-bedrock-vpc"
cluster_name        = "project-bedrock-cluster"
app_namespace       = "retail-app"
developer_user_name = "bedrock-dev-view"
lambda_name         = "bedrock-asset-processor"

vpc_cidr             = "10.42.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
single_nat_gateway   = true

# Check oldest EKS standard-support version before deploy:
# https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
cluster_version       = "1.34"
node_instance_types   = ["t3.small"]
node_desired_size     = 2
node_min_size         = 2
node_max_size         = 3 # Cluster Autoscaler ceiling (bonus 5.3)
node_disk_size        = 20
install_helm_on_nodes = true
log_retention_days    = 1

mysql_engine_version    = "8.0"
postgres_engine_version = "16"
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20
backup_retention_days   = 1

chart_version             = "1.6.2"
enable_app_deploy         = true  # ALB controller + Cluster Autoscaler + carts IRSA (shop = k8s pipeline)
enable_network_policies   = false # NetworkPolicies come from k8s/networkpolicies/
enable_cluster_autoscaler = true

budget_limit_usd          = 20
budget_notification_email = "lemikanemmanuel@gmail.com"

ui_hostname         = "lemikan-third-semester-exam-project.fyi"
acm_certificate_arn = "arn:aws:acm:us-east-1:193854996687:certificate/1bafcd3e-d5a7-4783-af09-e5afe2180aa7"

# EKS public API allow-list (kubectl / CI → cluster endpoint, not the shop ALB).
# IPv4 only — this cluster is IPv4, so EKS rejects IPv6 CIDRs (e.g. 2001:4860:7:1620::fc).
# 0.0.0.0/0 stays so GitHub-hosted Actions can reach the API (runner IPs are dynamic
# and do not fit in EKS's CIDR quota). IAM / EKS Access Entries still authorize who
# can actually run commands.
admin_access_cidrs = [
  "197.211.59.58/32", # my current public IPv4
  "0.0.0.0/0",        # GitHub Actions hosted runners
]
