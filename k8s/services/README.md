# services/

Stable in-cluster DNS so UI can call `http://catalog`, `http://orders`, and so on.

Pod IPs change. Service names do not. UI is **ClusterIP** too — public entry is the [Ingress](../ingress/README.md), not a second load balancer.

| File | DNS name | Port |
| --- | --- | --- |
| [ui.yaml](ui.yaml) | `ui.retail-app.svc` | 80 |
| [catalog.yaml](catalog.yaml) | `catalog` | 80 |
| [carts.yaml](carts.yaml) | `carts` | 80 |
| [orders.yaml](orders.yaml) | `orders` | 80 |
| [checkout.yaml](checkout.yaml) | `checkout` | 80 |
| [checkout-redis.yaml](checkout-redis.yaml) | `checkout-redis` | 6379 |
| [orders-rabbitmq.yaml](orders-rabbitmq.yaml) | `orders-rabbitmq` | 5672, 15672 |

Port 80 on each app Service maps to container `8080`. Selectors must match pod labels (`app.kubernetes.io/name` + `component`).

I do not add Services for MySQL, Postgres, or DynamoDB Local. Those endpoints come from RDS and DynamoDB.
