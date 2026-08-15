# secrets/

## Aim

Pods still **consume** Kubernetes Secrets (`catalog-db`, `orders-db`, `orders-rabbitmq`). Git must **never** contain the values.

A Kubernetes Secret in YAML is only base64. Committing it is publishing the password.

## Why AWS Secrets Manager for the databases

Terraform’s `data` module already creates:

- `bedrock/catalog-db` — username, password, host, port, dbname
- `bedrock/orders-db` — same shape for Postgres

```bash
./scripts/k8s-sync-secrets.sh
```

That writes (in-cluster only):

| Secret | Keys |
| --- | --- |
| `catalog-db` | `RETAIL_CATALOG_PERSISTENCE_USER`, `_PASSWORD`, `_ENDPOINT` |
| `orders-db` | `RETAIL_ORDERS_PERSISTENCE_USERNAME`, `_PASSWORD`, `_ENDPOINT` |
| `orders-rabbitmq` | `RETAIL_ORDERS_MESSAGING_RABBITMQ_USERNAME`, `_PASSWORD` (generated here; RabbitMQ is in-cluster, not in Secrets Manager) |

It also annotates ServiceAccount `carts` with IRSA when the role exists.

An empty RabbitMQ secret is **not** used: RabbitMQ 3 refuses a blank password, and `envFrom` would make orders log in as user `''`. The sync script creates a real user/password and the StatefulSet reads the same keys as `RABBITMQ_DEFAULT_USER` / `RABBITMQ_DEFAULT_PASS`.

Helm stage 2 copies RDS secrets via `kubernetes_secret_v1` in `k8s-apps`. Use YAML **or** Helm, not both.

## What is in git

Nothing with Secret `data`. This folder is documentation only.

`.gitignore` blocks `catalog-db.yaml` and `orders-db.yaml` if they appear.

## If `git status` shows a DB Secret

Do not commit it. Delete the file and re-run `k8s-sync-secrets.sh`.
