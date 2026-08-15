# serviceaccounts/

One identity per app in `retail-app`.

Only carts should reach DynamoDB. If every pod used `default`, one annotation would grant that to everyone — so I split the ServiceAccounts.

Names match Helm (`catalog`, `carts`, `orders`, `checkout`, `ui`). `./scripts/k8s-sync-secrets.sh` annotates `carts` with IRSA from role `project-bedrock-cluster-carts` (or `CARTS_IRSA_ROLE_ARN`). The role ARN is not in git.

| File | Used by |
| --- | --- |
| [catalog.yaml](catalog.yaml) | catalog |
| [carts.yaml](carts.yaml) | carts (IRSA) |
| [orders.yaml](orders.yaml) | orders |
| [checkout.yaml](checkout.yaml) | checkout |
| [ui.yaml](ui.yaml) | ui |

Redis and RabbitMQ use the namespace default SA. They do not talk to AWS.
