output "catalog_endpoint" {
  description = "MySQL host:port for the catalog service."
  value       = "${module.catalog_mysql.db_instance_address}:${module.catalog_mysql.db_instance_port}"
}

output "catalog_username" {
  description = "Catalog DB username."
  value       = "catalog"
}

output "catalog_password" {
  description = "Catalog DB password. Injected into Kubernetes; never a root output."
  value       = random_password.mysql.result
  sensitive   = true
}

output "orders_endpoint" {
  description = "PostgreSQL host:port for the orders service."
  value       = "${module.orders_postgres.db_instance_address}:${module.orders_postgres.db_instance_port}"
}

output "orders_username" {
  description = "Orders DB username (not admin — RDS forbids it)."
  value       = "dbadmin"
}

output "orders_password" {
  description = "Orders DB password. Injected into Kubernetes; never a root output."
  value       = random_password.postgres.result
  sensitive   = true
}

output "dynamodb_table_name" {
  description = "Carts DynamoDB table name."
  value       = module.carts_dynamodb.dynamodb_table_id
}

output "dynamodb_table_arn" {
  description = "Carts DynamoDB table ARN."
  value       = module.carts_dynamodb.dynamodb_table_arn
}
