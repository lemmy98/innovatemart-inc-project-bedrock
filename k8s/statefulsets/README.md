# statefulsets/

## Aim

Run **RabbitMQ** with a predictable identity so the orders app can always dial `orders-rabbitmq:5672`.

## Why a StatefulSet, and only this one

Orders talks to RabbitMQ by hostname. A Deployment’s pod name changes every reschedule (`orders-rabbitmq-7f9c…`). A StatefulSet keeps `orders-rabbitmq-0` and the headless-style `serviceName: orders-rabbitmq`.

We **do not** put catalog MySQL or orders Postgres here. Those look like StatefulSets in the upstream dump because they were laptop databases. On EKS that data is RDS. Putting them back would fail the exam.

Redis for checkout is a Deployment ([deployments/checkout-redis.yaml](../deployments/checkout-redis.yaml)): no identity requirement, emptyDir is enough, exam does not ask for persistence.

## What we aim to achieve

- One replica (RAM).
- User/password from Secret `orders-rabbitmq` (created by `k8s-sync-secrets.sh`, not git).
- `emptyDir` for mnesia — acceptable for a student cluster that will be destroyed; a real shop would use a PVC.
- TCP probes on AMQP (5672), not the management UI.
- Small requests/limits so it fits next to four JVMs on `t3.small`.

## Files

| File | Workload |
| --- | --- |
| [orders-rabbitmq.yaml](orders-rabbitmq.yaml) | RabbitMQ 3 management image |

Paired Service: [services/orders-rabbitmq.yaml](../services/orders-rabbitmq.yaml).
