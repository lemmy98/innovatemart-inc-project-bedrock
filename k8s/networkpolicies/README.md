# networkpolicies/

## Aim

Make “who may talk to whom” **explicit**. Default is deny inbound; then we open only the paths the shop actually uses.

This is the exam bonus, same idea as Terraform `k8s-apps` NetworkPolicies.

## Why default-deny first

Without a default deny, a typo in one policy is an open cluster. With it, a missing allow shows up as a timeout — noisy, but safe.

```
ui          ← internet (ALB → 8080)
ui          → catalog, carts, checkout, orders :80
catalog     → RDS :3306
carts       → DynamoDB :443
checkout    → orders :80, redis :6379
orders      → Postgres :5432, RabbitMQ :5672
redis       ← checkout only
rabbitmq    ← orders only
```

DNS (53 TCP/UDP) is allowed so pods can resolve Service and RDS names. We do not pin DNS to `kube-system` so the policies stay portable.

## What we aim to achieve

- UI ingress is **not** restricted to a pod source — the ALB target-type IP traffic does not look like a pod in this namespace.
- Carts egress is **443 only** (AWS APIs), not a local `:8000`. That is intentional: DynamoDB Local is not part of this install.
- Policies select `app.kubernetes.io/name` (+ `component` where Redis/RabbitMQ share a name with the app).

## Files

| File | Covers |
| --- | --- |
| [default-deny.yaml](default-deny.yaml) | All pods, Ingress deny |
| [ui.yaml](ui.yaml) | Storefront |
| [catalog.yaml](catalog.yaml) | Catalog + MySQL egress |
| [carts.yaml](carts.yaml) | Carts + DynamoDB egress |
| [checkout.yaml](checkout.yaml) | Checkout + Redis + orders |
| [orders.yaml](orders.yaml) | Orders + Postgres + AMQP |
| [checkout-redis.yaml](checkout-redis.yaml) | Redis accept from checkout |
| [orders-rabbitmq.yaml](orders-rabbitmq.yaml) | RabbitMQ accept from orders |

EKS needs a CNI that enforces NetworkPolicy (Amazon VPC CNI policy addon, or Calico). Stage-1 cluster should have that if `enable_network_policies` is on in Terraform; this folder is the YAML equivalent.
