# configmaps/

Non-secret settings I give the pods — persistence provider, in-cluster URLs, UI theme, DynamoDB table name.

I keep these in ConfigMaps because they are easy to `kubectl get`. Passwords, RDS hosts, and AWS keys do not belong here.

| Lives in ConfigMap | Lives in a Secret |
| --- | --- |
| `provider: mysql` / `postgres` / `dynamodb` / `redis` | Username + password |
| Database **name** (`catalog`, `orders`) | RDS **endpoint** `host:port` |
| `http://catalog`, `orders-rabbitmq:5672`, Redis URL | — |
| DynamoDB table `bedrock-carts`, `createTable: false` | — (IRSA, not static keys) |

| File | Consumed by |
| --- | --- |
| [ui.yaml](ui.yaml) | ui |
| [catalog.yaml](catalog.yaml) | catalog |
| [carts.yaml](carts.yaml) | carts |
| [orders.yaml](orders.yaml) | orders |
| [checkout.yaml](checkout.yaml) | checkout |

Carts has **no** `AWS_ACCESS_KEY_ID`. Catalog/orders have **no** hard-coded RDS hostnames — those come from Secrets Manager at sync time.
