# configmaps/

## Aim

Hold **non-secret** settings: which persistence provider, in-cluster URLs, UI theme, DynamoDB table name.

Passwords, DB hosts from RDS, and AWS keys do **not** belong here.

## Why split from Secrets

ConfigMaps are visible to anyone with `get configmap` and they show up in `kubectl describe`. Mixing `RETAIL_ORDERS_PERSISTENCE_PASSWORD` into the same object as `RETAIL_ORDERS_PERSISTENCE_PROVIDER` is how student repos leak credentials.

| Lives in ConfigMap | Lives in a Secret (from Secrets Manager) |
| --- | --- |
| `provider: mysql` / `postgres` / `dynamodb` / `redis` | Username + password |
| Database **name** (`catalog`, `orders`) | RDS **endpoint** `host:port` |
| `http://catalog`, `orders-rabbitmq:5672`, Redis URL | — |
| DynamoDB table `bedrock-carts`, `createTable: false` | — (IRSA, not static keys) |

Pods `envFrom` both objects. The app libraries read `RETAIL_*` env vars either way.

## What we aim to achieve

- Carts ConfigMap has **no** `AWS_ACCESS_KEY_ID`. That was a DynamoDB Local hack. On EKS, the `carts` ServiceAccount uses IRSA.
- Catalog/orders ConfigMaps have **no** `*:3306` / `*:5432` hostnames. Those come from Secrets Manager at sync time so a laptop copy of this repo cannot point at a stale RDS address.
- UI endpoints stay in-cluster HTTP — the browser never talks to catalog directly; the UI pod does.

## Files

| File | Consumed by |
| --- | --- |
| [ui.yaml](ui.yaml) | ui |
| [catalog.yaml](catalog.yaml) | catalog |
| [carts.yaml](carts.yaml) | carts |
| [orders.yaml](orders.yaml) | orders |
| [checkout.yaml](checkout.yaml) | checkout |
