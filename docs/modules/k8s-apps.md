# k8s-apps (cluster platform)

## What it is

When `enable_app_deploy = true`, this module installs **platform** pieces only:

1. AWS Load Balancer Controller (IRSA + Helm in `kube-system`)
2. Cluster Autoscaler when `enable_cluster_autoscaler = true`
3. Carts DynamoDB IRSA role (annotated onto SA `carts` by `scripts/k8s-sync-secrets.sh`)

The **shop** (ui, catalog, carts, orders, checkout, NetworkPolicies, Ingress) is **not** installed here.

## How the shop is applied

```bash
# CI: Actions → K8s Deploy (or push under k8s/)
# Laptop:
./scripts/k8s-up.sh
```

That runs Secrets Manager sync, then `kubectl apply -k k8s/`.

Helm umbrella [`helm/retail-store`](../../../helm/retail-store) remains for bonus 5.1 demos — do **not** Helm-install while the YAML path is live on the same cluster.

## Why not Terraform Helm for the shop

Terraform owning every chart release fights Secrets Manager ownership, stuck failed releases, and chart value quirks. AWS stays in Terraform; Kubernetes YAML stays in `k8s/` + pipeline.
