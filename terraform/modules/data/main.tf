resource "random_password" "mysql" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+"
}

resource "random_password" "postgres" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+"
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds"
  description = "Allow MySQL and PostgreSQL only from EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rds" })
}

module "catalog_mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12"

  identifier = "${var.name_prefix}-catalog-mysql"

  engine               = "mysql"
  engine_version       = var.mysql_engine_version
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "catalog"
  username = "catalog"
  password = random_password.mysql.result
  port     = 3306

  manage_master_user_password = false
  multi_az                    = false
  publicly_accessible         = false
  create_db_subnet_group      = true
  subnet_ids                  = var.private_subnet_ids
  vpc_security_group_ids      = [aws_security_group.rds.id]

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection                 = false
  skip_final_snapshot                 = true
  performance_insights_enabled        = false
  create_cloudwatch_log_group         = false
  enabled_cloudwatch_logs_exports     = []
  iam_database_authentication_enabled = false

  parameters = [
    {
      name  = "require_secure_transport"
      value = "0"
    }
  ]

  tags = merge(var.tags, { Name = "${var.name_prefix}-catalog-mysql" })
}

module "orders_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12"

  identifier = "${var.name_prefix}-orders-pg"

  engine               = "postgres"
  engine_version       = var.postgres_engine_version
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "orders"
  username = "dbadmin"
  password = random_password.postgres.result
  port     = 5432

  manage_master_user_password = false
  multi_az                    = false
  publicly_accessible         = false
  create_db_subnet_group      = true
  subnet_ids                  = var.private_subnet_ids
  vpc_security_group_ids      = [aws_security_group.rds.id]

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection             = false
  skip_final_snapshot             = true
  performance_insights_enabled    = false
  create_cloudwatch_log_group     = false
  enabled_cloudwatch_logs_exports = []

  parameters = [
    {
      name  = "rds.force_ssl"
      value = "0"
    }
  ]

  tags = merge(var.tags, { Name = "${var.name_prefix}-orders-pg" })
}

module "carts_dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.2"

  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "customerId"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "idx_global_customerId"
      hash_key        = "customerId"
      projection_type = "ALL"
    }
  ]

  tags = merge(var.tags, { Name = var.dynamodb_table_name })
}

resource "aws_secretsmanager_secret" "catalog" {
  name                    = "${var.name_prefix}/catalog-db"
  recovery_window_in_days = 0
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-catalog-db" })
}

resource "aws_secretsmanager_secret_version" "catalog" {
  secret_id = aws_secretsmanager_secret.catalog.id
  secret_string = jsonencode({
    username = "catalog"
    password = random_password.mysql.result
    engine   = "mysql"
    host     = module.catalog_mysql.db_instance_address
    port     = module.catalog_mysql.db_instance_port
    dbname   = "catalog"
  })
}

resource "aws_secretsmanager_secret" "orders" {
  name                    = "${var.name_prefix}/orders-db"
  recovery_window_in_days = 0
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-orders-db" })
}

resource "aws_secretsmanager_secret_version" "orders" {
  secret_id = aws_secretsmanager_secret.orders.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.postgres.result
    engine   = "postgres"
    host     = module.orders_postgres.db_instance_address
    port     = module.orders_postgres.db_instance_port
    dbname   = "orders"
  })
}
