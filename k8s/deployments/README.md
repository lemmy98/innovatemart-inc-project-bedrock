# deployments/

## Aim

Run the five shop processes (and checkout’s Redis) as **stateless** replicas that can die and come back without losing catalog/orders/carts data.

## Why Deployments here

Catalog, carts, orders, checkout, and ui keep their data in RDS, DynamoDB, or (for checkout) a separate Redis pod. A Deployment is the right primitive: rolling updates, `maxUnavailable: 1`, no sticky volume.

RabbitMQ is the exception — it needs a stable DNS name (`orders-rabbitmq-0.orders-rabbitmq`). That lives in [statefulsets/](../statefulsets/README.md).

## What we aim to achieve

- **Pinned images** `…:1.6.2` — same upstream release as the Helm charts.
- **Requests/limits sized for `t3.small`** — the upstream all-in-one YAML asked for 256–512 Mi and 256m CPU per Java pod; two nodes cannot schedule that. These numbers match `helm/retail-store/values.yaml`.
- **Readiness + liveness** — ALB and kubelet should not send traffic to a JVM that is still booting.
- **Dropped capabilities, non-root, read-only root FS** — baseline hardening from the sample, kept on purpose.
- **`envFrom` ConfigMap + Secret** — config and credentials stay out of the container spec.

## Files

| File | Workload |
| --- | --- |
| [ui.yaml](ui.yaml) | Storefront (port 8080, Service 80) |
| [catalog.yaml](catalog.yaml) | Product API → RDS MySQL |
| [carts.yaml](carts.yaml) | Cart API → DynamoDB |
| [orders.yaml](orders.yaml) | Orders API → RDS Postgres + RabbitMQ |
| [checkout.yaml](checkout.yaml) | Checkout API → Redis + orders |
| [checkout-redis.yaml](checkout-redis.yaml) | Redis 6 for checkout only |

`replicas: 1` everywhere. Two `t3.small` nodes are already tight; HA is a later conversation, not this exam.

## What is deliberately missing

No `catalog-mysql`, `orders-postgresql`, or `carts-dynamodb` Deployments. Those were the upstream laptop databases. On EKS they fail the managed-data requirement.
