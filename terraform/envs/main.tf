# Stage 1: cloud resources. Stage 2: set enable_app_deploy = true after nodes are Ready.

module "networking" {
  source = "../modules/networking"

  name                 = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.required_tags
}

module "serverless" {
  source = "../modules/serverless"

  bucket_name        = local.assets_bucket
  lambda_name        = var.lambda_name
  lambda_source_dir  = "${path.module}/../../lambda"
  log_retention_days = var.log_retention_days
  tags               = local.required_tags
}

module "iam_developer" {
  source = "../modules/iam-developer"

  user_name         = var.developer_user_name
  assets_bucket_arn = module.serverless.bucket_arn
  tags              = local.required_tags
}

module "eks" {
  source = "../modules/eks"

  cluster_name            = var.cluster_name
  cluster_version         = var.cluster_version
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = concat(module.networking.private_subnet_ids, module.networking.public_subnet_ids)
  private_subnet_ids      = module.networking.private_subnet_ids
  node_instance_types     = var.node_instance_types
  node_desired_size       = var.node_desired_size
  node_min_size           = var.node_min_size
  node_max_size           = var.node_max_size
  node_disk_size          = var.node_disk_size
  install_helm_on_nodes   = var.install_helm_on_nodes
  log_retention_days      = var.log_retention_days
  app_namespace           = var.app_namespace
  developer_principal_arn = module.iam_developer.user_arn
  tags                    = local.required_tags
}

module "data" {
  source = "../modules/data"

  name_prefix             = local.name_prefix
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  node_security_group_id  = module.eks.node_security_group_id
  mysql_engine_version    = var.mysql_engine_version
  postgres_engine_version = var.postgres_engine_version
  db_instance_class       = var.db_instance_class
  db_allocated_storage    = var.db_allocated_storage
  backup_retention_days   = var.backup_retention_days
  dynamodb_table_name     = "${local.name_prefix}-carts"
  tags                    = local.required_tags
}

module "budget" {
  source = "../modules/budget"

  name               = "${local.name_prefix}-${var.environment}-budget"
  limit_usd          = var.budget_limit_usd
  notification_email = var.budget_notification_email
  project_tag        = var.project_tag
}

module "k8s_apps" {
  count  = var.enable_app_deploy ? 1 : 0
  source = "../modules/k8s-apps"

  cluster_name            = module.eks.cluster_name
  aws_region              = var.aws_region
  app_namespace           = var.app_namespace
  chart_version           = var.chart_version
  oidc_provider_arn       = module.eks.oidc_provider_arn
  catalog_endpoint        = module.data.catalog_endpoint
  catalog_username        = module.data.catalog_username
  catalog_password        = module.data.catalog_password
  orders_endpoint         = module.data.orders_endpoint
  orders_username         = module.data.orders_username
  orders_password         = module.data.orders_password
  dynamodb_table_name     = module.data.dynamodb_table_name
  dynamodb_table_arn      = module.data.dynamodb_table_arn
  enable_network_policies = var.enable_network_policies
  tags                    = local.required_tags

  depends_on = [module.eks, module.data]
}
