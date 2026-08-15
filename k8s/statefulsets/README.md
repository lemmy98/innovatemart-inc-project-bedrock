# statefulsets/

RabbitMQ with a stable name so orders can dial `orders-rabbitmq:5672`.

A Deployment’s pod name changes every reschedule. A StatefulSet keeps `orders-rabbitmq-0`, which is why I use it here. Catalog MySQL and orders Postgres are **RDS**, not StatefulSets in this folder.

One replica. User/password from Secret `orders-rabbitmq` (created by `k8s-sync-secrets.sh`, not git). `emptyDir` for mnesia. TCP probes on AMQP 5672.

File: [orders-rabbitmq.yaml](orders-rabbitmq.yaml). Service: [services/orders-rabbitmq.yaml](../services/orders-rabbitmq.yaml).

Checkout Redis is a Deployment — no identity requirement. See [deployments/checkout-redis.yaml](../deployments/checkout-redis.yaml).
