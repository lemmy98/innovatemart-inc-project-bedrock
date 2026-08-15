# secrets/

Pods read Kubernetes Secrets (`catalog-db`, `orders-db`, `orders-rabbitmq`). Git must never contain the values.

A Secret in YAML is only base64. If I commit it, I publish the password.

Terraform already stores `bedrock/catalog-db` and `bedrock/orders-db` in Secrets Manager. I sync them in-cluster:

```bash
./scripts/k8s-sync-secrets.sh
```

| Secret | Keys |
| --- | --- |
| `catalog-db` | `RETAIL_CATALOG_PERSISTENCE_USER`, `_PASSWORD`, `_ENDPOINT` |
| `orders-db` | `RETAIL_ORDERS_PERSISTENCE_USERNAME`, `_PASSWORD`, `_ENDPOINT` |
| `orders-rabbitmq` | `RETAIL_ORDERS_MESSAGING_RABBITMQ_USERNAME`, `_PASSWORD` (generated here; RabbitMQ is in-cluster) |

The script also annotates ServiceAccount `carts` with IRSA when the role exists. RabbitMQ needs a real password (blank fails). Helm copies RDS secrets another way — I use YAML **or** Helm, not both.

This folder is documentation only. `.gitignore` blocks `catalog-db.yaml` and `orders-db.yaml`. If `git status` shows a DB Secret, I delete it and re-run the sync script.
