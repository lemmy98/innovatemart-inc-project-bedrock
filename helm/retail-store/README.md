# helm/retail-store

This is how I install the shop with **Helm**: an umbrella for catalog, carts, orders, checkout, ui (upstream **v1.6.2**). Helm = installer for Kubernetes apps.

I use this for exam bonus 5.1. Same shop as `k8s/`, but as a chart. `values.yaml` points at RDS + DynamoDB — no in-cluster MySQL/Postgres/DDB.

After EKS nodes are Ready and Terraform `enable_app_deploy` has installed the ALB controller:

```bash
./scripts/helm-up.sh
./scripts/helm-down.sh
```

If YAML is already live, I run `REPLACE_EXISTING=1 ./scripts/helm-up.sh` first (or use Actions → **Helm Deploy** with replace). That flag is opt-in — I do not pass it by default. I pick **one** path: Helm or [`k8s/`](../../k8s/README.md).
