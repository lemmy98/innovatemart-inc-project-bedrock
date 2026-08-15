# networkpolicies/

Default-deny inbound, then I allow only the paths the shop uses. Exam bonus 5.4.

Without a default deny, a typo leaves the cluster open. With it, a missing allow shows up as a timeout — easier for me to debug.

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

DNS (53 TCP/UDP) is allowed so pods can resolve Service and RDS names.

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

UI ingress is not limited to a pod source (ALB traffic is not a pod in this namespace). Carts egress is **443 only** — no DynamoDB Local. EKS needs a CNI that enforces NetworkPolicy.
