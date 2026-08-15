# data

## What it is

The exam’s “replace Compose databases” layer:

| App need | AWS resource | Notes |
| --- | --- | --- |
| Catalog | RDS MySQL 8, DB `catalog`, user `catalog` | `db.t3.micro`, 20 GiB, private |
| Orders | RDS PostgreSQL 16, DB `orders`, user `dbadmin` | `admin` is reserved on RDS |
| Carts | DynamoDB `bedrock-carts` | Hash `id`, GSI `idx_global_customerId` |

Passwords: `random_password` → Secrets Manager. Never root Terraform outputs.  
The YAML path copies them into Kubernetes with `./scripts/k8s-sync-secrets.sh` ([k8s/secrets/README.md](../../k8s/secrets/README.md)). Helm stage 2 does the same inside the `k8s-apps` module.

## Why

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Managed RDS/DynamoDB | Exam core requirement | Stable, inspectable, not lost when a pod dies |
| SG only from node SG | Databases should not be on the internet | Least privilege network path |
| `skip_final_snapshot = true` | Student projects get destroyed often | `terraform destroy` does not stick on snapshot prompts |
| Secrets Manager | Need a durable secret store before Kubernetes exists | Stage 2 can copy into K8s secrets safely |
