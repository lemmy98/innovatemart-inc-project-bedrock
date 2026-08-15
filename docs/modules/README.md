# Modules

Each folder under `terraform/modules/` owns one concern. `terraform/envs/main.tf` wires them together.

We wrap well-known community modules (`terraform-aws-modules/vpc`, `eks`, `rds`, `dynamodb-table`) so we are not inventing VPC/EKS from scratch. Versions are pinned in each module’s `main.tf`.

| Module | Stage | Job |
| --- | --- | --- |
| [networking](networking.md) | 1 | VPC, subnets, one NAT |
| [eks](eks.md) | 1 | Cluster, nodes, access entries, add-ons |
| [data](data.md) | 1 | MySQL, Postgres, DynamoDB, Secrets Manager |
| [iam-developer](iam-developer.md) | 1 | `bedrock-dev-view` user |
| [serverless](serverless.md) | 1 | Assets bucket + Lambda |
| [budget](budget.md) | 1 | Cost alarm on the project tag |
| [k8s-apps](k8s-apps.md) | 2 | Helm releases + ALB controller + Cluster Autoscaler (off until Ready) |

Module folder `README.md` files only point here so we do not maintain two write-ups.
