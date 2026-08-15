# Modules

Each folder under `terraform/modules/` owns one concern. `terraform/envs/main.tf` is where I wire them together.

I wrap community modules (`vpc`, `eks`, `rds`, `dynamodb-table`) instead of inventing those from scratch. Versions are pinned in each module’s `main.tf`.

| Module | Stage | Job |
| --- | --- | --- |
| [networking](networking.md) | 1 | VPC, subnets, one NAT |
| [eks](eks.md) | 1 | Cluster, nodes, access entries, add-ons |
| [data](data.md) | 1 | MySQL, Postgres, DynamoDB, Secrets Manager |
| [iam-developer](iam-developer.md) | 1 | `bedrock-dev-view` user |
| [serverless](serverless.md) | 1 | Assets bucket + Lambda `bedrock-asset-processor` |
| [budget](budget.md) | 1 | Cost alarm on tag `Project=tinyuka-2025-capstone` |
| [k8s-apps](k8s-apps.md) | 2 | ALB controller + Cluster Autoscaler + carts IRSA (off until nodes are Ready) |

Folder `README.md` files only point here so I do not maintain two write-ups.
