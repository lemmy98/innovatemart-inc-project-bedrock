# Upstream sample app

We use the official [aws-containers/retail-store-sample-app](https://github.com/aws-containers/retail-store-sample-app) **v1.6.2**.

The pin lives in three places that must stay in sync:

| Where | What |
| --- | --- |
| `k8s/deployments/*.yaml` | Image tags `public.ecr.aws/aws-containers/retail-store-sample-*:1.6.2` |
| `helm/retail-store/Chart.yaml` | Subchart versions `1.6.2` from `oci://public.ecr.aws/aws-containers` |
| `terraform/envs/prod.tfvars` | `chart_version = "1.6.2"` |

There is no `vendor/` copy. The upstream all-in-one `kubernetes.yaml` recreates in-cluster MySQL / Postgres / DynamoDB Local. Our install is [`k8s/`](../../k8s/README.md) (or Helm stage 2), which points catalog/orders/carts at RDS + DynamoDB.

## Why we diverge on EKS

Upstream Compose uses MariaDB, DynamoDB Local, Postgres, RabbitMQ, Redis, and optional OpenSearch. The exam wants catalog/orders/carts on **AWS managed** services. So Helm values and the YAML ConfigMaps set:

- no in-cluster MySQL / Postgres / DynamoDB Local
- endpoints from Secrets Manager / IRSA

Redis and RabbitMQ remain pods (exam allows it). OpenSearch is skipped: too heavy for `t3.small` nodes.

## Refresh (rare)

Pull chart tarballs with `helm dependency update helm/retail-store`.  
Re-read image tags from the [v1.6.2 release](https://github.com/aws-containers/retail-store-sample-app/releases/tag/v1.6.2) if you bump the pin — change tfvars, Chart.yaml, and `k8s/deployments/` together.
