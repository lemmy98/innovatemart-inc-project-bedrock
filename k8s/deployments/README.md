# deployments/

The five shop processes plus checkout Redis, as Deployments.

Catalog/orders/carts data lives in RDS or DynamoDB, so pods can die and come back. RabbitMQ needs a stable name, so I put it in [statefulsets/](../statefulsets/README.md).

Pinned images `…:1.6.2`, requests/limits sized for `t3.small`, readiness + liveness, `envFrom` ConfigMap + Secret. `replicas: 1` everywhere.

| File | Workload |
| --- | --- |
| [ui.yaml](ui.yaml) | Storefront (port 8080, Service 80) |
| [catalog.yaml](catalog.yaml) | Product API → RDS MySQL |
| [carts.yaml](carts.yaml) | Cart API → DynamoDB |
| [orders.yaml](orders.yaml) | Orders API → RDS Postgres + RabbitMQ |
| [checkout.yaml](checkout.yaml) | Checkout API → Redis + orders |
| [checkout-redis.yaml](checkout-redis.yaml) | Redis 6 for checkout only |

I do not add `catalog-mysql`, `orders-postgresql`, or `carts-dynamodb` Deployments. Those were laptop databases and fail the exam on EKS.
