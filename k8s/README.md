# k8s/ — shop YAML

This folder *is* my shop manifests for namespace `retail-app`. There is no separate `manifests/` tree.

The exam allows YAML **or** Helm. This is how I bring the shop up with YAML. I never apply the vendor `kubernetes.yaml` — it starts in-cluster MySQL/Postgres/DynamoDB and fails the exam.

After EKS nodes are Ready and Terraform `enable_app_deploy` has installed the **ALB** controller:

```bash
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster
./scripts/k8s-up.sh
kubectl -n retail-app get pods,ingress
./scripts/k8s-down.sh          # deletes namespace retail-app only — not AWS
```

`k8s-up.sh` syncs Secrets Manager, then `kubectl apply -k k8s/`. CI: **K8s Deploy**. Helm alternative: [`helm/retail-store`](../helm/retail-store). I pick **one**.

## Traffic

```
internet → ALB (Ingress) → ui:80
                ├─ catalog  → RDS MySQL      (Secrets Manager)
                ├─ carts    → DynamoDB       (IRSA, no access keys)
                ├─ orders   → RDS Postgres   (Secrets Manager)
                │                + RabbitMQ pod
                └─ checkout → Redis pod → orders
```

Images: official sample **v1.6.2**. See [docs/app/upstream.md](../docs/app/upstream.md).

## Folders

| Path | Role |
| --- | --- |
| [namespace.yaml](namespace.yaml) | Exam namespace `retail-app` |
| [kustomization.yaml](kustomization.yaml) | Apply list + namespace injection |
| [serviceaccounts/](serviceaccounts/README.md) | Identities; carts IRSA for DynamoDB |
| [secrets/](secrets/README.md) | No DB passwords in git |
| [configmaps/](configmaps/README.md) | Non-secret config |
| [services/](services/README.md) | ClusterIP mesh; UI is not a LoadBalancer |
| [deployments/](deployments/README.md) | App pods + checkout Redis |
| [statefulsets/](statefulsets/README.md) | RabbitMQ only |
| [ingress/](ingress/README.md) | Public URL via ALB |
| [networkpolicies/](networkpolicies/README.md) | Default-deny + allow-lists (bonus 5.4) |

I do not `kubectl apply -f` a random file unless I know it is namespaced.

## Data (must match Terraform `data`)

| App | Store | How the pod learns it |
| --- | --- | --- |
| catalog | RDS MySQL | Secret `catalog-db` |
| orders | RDS Postgres | Secret `orders-db` |
| carts | DynamoDB `bedrock-carts` | ConfigMap table name + IRSA on SA `carts` |
| checkout | Redis **pod** | ConfigMap URL |
| orders messaging | RabbitMQ **pod** | ConfigMap address |

Secrets Manager names: `bedrock/catalog-db`, `bedrock/orders-db`.

## Rules I follow

- I never commit Secret `data` / `stringData` for databases.
- I never add in-cluster MySQL, Postgres, or DynamoDB Local.
- Redis and RabbitMQ stay in-cluster (allowed).
- I do not Helm-install while this folder is applied on the same cluster.
