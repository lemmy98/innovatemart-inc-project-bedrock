# services/

## Aim

Give every workload a **stable in-cluster DNS name** so UI and checkout can call `http://catalog`, `http://orders`, and so on without caring which pod IP is current.

## Why ClusterIP (including UI)

| Service | Type | Why |
| --- | --- | --- |
| catalog, carts, orders, checkout | ClusterIP | East-west only. Never on the internet. |
| checkout-redis, orders-rabbitmq | ClusterIP | Sidecar-style data planes for one app each. |
| **ui** | **ClusterIP** | Public entry is the [Ingress](../ingress/README.md), not a second AWS load balancer. |

Upstream used `LoadBalancer` on UI. That fights the ALB Ingress and costs extra. We do not copy that.

Port 80 on the Service → container port `http` (8080) so Ingress and in-cluster clients can use short URLs (`http://catalog`, `http://ui`).

## Files

| File | DNS name | Port |
| --- | --- | --- |
| [ui.yaml](ui.yaml) | `ui.retail-app.svc` | 80 |
| [catalog.yaml](catalog.yaml) | `catalog` | 80 |
| [carts.yaml](carts.yaml) | `carts` | 80 |
| [orders.yaml](orders.yaml) | `orders` | 80 |
| [checkout.yaml](checkout.yaml) | `checkout` | 80 |
| [checkout-redis.yaml](checkout-redis.yaml) | `checkout-redis` | 6379 |
| [orders-rabbitmq.yaml](orders-rabbitmq.yaml) | `orders-rabbitmq` | 5672, 15672 |

Selectors must match the pod labels in [deployments/](../deployments/README.md) / [statefulsets/](../statefulsets/README.md) (`app.kubernetes.io/name` + `component`). If those drift, the Service silently has no endpoints.

## What is not here

No Services for MySQL, Postgres, or DynamoDB Local. Those endpoints come from RDS and DynamoDB, injected via Secrets / IRSA.
