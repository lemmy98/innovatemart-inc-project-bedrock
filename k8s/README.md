# k8s/ — the shop, as YAML

**There is no separate `manifests/` folder.** This directory *is* the manifests. Every Deployment, Service, Ingress, NetworkPolicy, ConfigMap, ServiceAccount, and StatefulSet lives here as YAML. Helm is a *second* path (`helm/retail-store`); it is not mixed into these files.

Exam allows YAML/Kustomize **or** Helm; this is the YAML path.

**Aim:** run InnovateMart in namespace `retail-app` on EKS, with catalog/orders/carts on **managed AWS data stores**, UI on an **internet ALB**, and no passwords in git.

Helm alternative: [`helm/retail-store`](../helm/retail-store) via Terraform `enable_app_deploy`. Pick **one** on EKS, never both.

## Why folders, not one giant file

A single dump (the upstream `kubernetes.yaml`) hides three exam failures:

1. In-cluster MySQL / Postgres / DynamoDB Local instead of RDS + DynamoDB
2. Database passwords committed as base64
3. UI as `LoadBalancer` instead of Ingress + ALB

Splitting by **resource type** (not by microservice) makes reviews and diffs honest: “where are the secrets?” → `secrets/`. “how does traffic enter?” → `ingress/`. Kustomize glues it back into one apply.

```bash
kubectl apply -k k8s/
```

`kustomization.yaml` injects `namespace: retail-app` onto every object and lists apply order. Do not `kubectl apply -f` a random file unless you know it is namespaced.

## What we are aiming at

```
internet → ALB (Ingress) → ui:80
                ├─ catalog  → RDS MySQL      (Secrets Manager)
                ├─ carts    → DynamoDB       (IRSA, no access keys)
                ├─ orders   → RDS Postgres   (Secrets Manager)
                │                + RabbitMQ pod
                └─ checkout → Redis pod → orders
```

Images are the official sample **v1.6.2** (`public.ecr.aws/aws-containers/retail-store-sample-*:1.6.2`). Chart version in tfvars is the same pin. No second copy of upstream in the repo — see [docs/app/upstream.md](../docs/app/upstream.md).

## Folder map

Each folder has its own README (why it exists, what “done” looks like).

| Path | Role |
| --- | --- |
| [namespace.yaml](namespace.yaml) | Exam namespace `retail-app` |
| [kustomization.yaml](kustomization.yaml) | The apply list + namespace injection |
| [serviceaccounts/](serviceaccounts/README.md) | Identities; carts IRSA for DynamoDB |
| [secrets/](secrets/README.md) | No DB passwords in git — AWS Secrets Manager |
| [configmaps/](configmaps/README.md) | Non-secret config only |
| [services/](services/README.md) | ClusterIP mesh; UI is not a LoadBalancer |
| [deployments/](deployments/README.md) | App pods + checkout Redis |
| [statefulsets/](statefulsets/README.md) | RabbitMQ only (stable network name) |
| [ingress/](ingress/README.md) | Public URL via AWS Load Balancer Controller |
| [networkpolicies/](networkpolicies/README.md) | Default-deny + allow-lists (exam bonus) |

## Apply (EKS, after stage 1 nodes are Ready)

Terraform (`enable_app_deploy`) must already have installed the **ALB controller**. Then:

```bash
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster
./scripts/k8s-sync-secrets.sh    # Secrets Manager → catalog-db / orders-db; carts IRSA
kubectl apply -k k8s/            # or ./scripts/k8s-up.sh (sync + apply + wait)
kubectl -n retail-app get pods,ingress
./scripts/k8s-down.sh            # deletes namespace retail-app only — not AWS
```

CI: GitHub Actions workflow **K8s Deploy** (push under `k8s/` or manual `workflow_dispatch`).

`k8s-up.sh` calls the sync script first unless `SKIP_SECRET_SYNC=1`.

## Data plane (must match Terraform `data` module)

| App | Store | How the pod learns it |
| --- | --- | --- |
| catalog | RDS MySQL | Secret `catalog-db` (user, password, `host:port`) |
| orders | RDS Postgres | Secret `orders-db` (user, password, `host:port`) |
| carts | DynamoDB `bedrock-carts` | ConfigMap table name + IRSA on SA `carts` |
| checkout | Redis **pod** | ConfigMap URL |
| orders messaging | RabbitMQ **pod** | ConfigMap address |

Secrets Manager: `bedrock/catalog-db`, `bedrock/orders-db`.

## Hard rules

- Never commit Secret `data` / `stringData` for databases.
- Never add in-cluster MySQL, Postgres, or DynamoDB Local here — that fails the exam.
- Redis and RabbitMQ stay in-cluster (allowed; cheaper than managed MQ).
- Do not Helm-install while this folder is applied on the same cluster.
