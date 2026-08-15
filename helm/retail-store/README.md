# helm/retail-store

Umbrella chart for catalog, carts, orders, checkout, ui (upstream **v1.6.2**).

`values.yaml` is the **EKS** overlay (RDS + DynamoDB; no in-cluster MySQL/Postgres/DDB).

## Deploy (EKS)

```bash
./scripts/helm-up.sh          # replaces YAML install in retail-app by default
./scripts/helm-down.sh        # remove Helm shop only
```

CI: Actions → **Helm Deploy** (push under `helm/` or `workflow_dispatch`).

YAML alternative: [`k8s/`](../../k8s/README.md) / **K8s Deploy**. Pick **one** on the cluster.

Terraform still installs the ALB controller + carts IRSA (`enable_app_deploy`).
