# serviceaccounts/

## Aim

Give each app its **own identity** in `retail-app`, so we can grant DynamoDB to carts and nothing else.

## Why not the `default` ServiceAccount

If every pod uses `default`, IRSA and NetworkPolicy both become blunt. One annotation on `default` would let catalog call DynamoDB. One SA per app is the smallest unit that matches the five charts.

## What we aim to achieve

- Names match the Helm charts (`catalog`, `carts`, `orders`, `checkout`, `ui`) so YAML and Helm stay interchangeable.
- **Carts** is the only SA that should receive `eks.amazonaws.com/role-arn`. `./scripts/k8s-sync-secrets.sh` annotates it from IAM role `project-bedrock-cluster-carts` (created with stage-2 Helm) or `CARTS_IRSA_ROLE_ARN`.
- We do not bake the role ARN into git — it is account-specific.

## Files

| File | Used by |
| --- | --- |
| [catalog.yaml](catalog.yaml) | catalog Deployment |
| [carts.yaml](carts.yaml) | carts Deployment (IRSA) |
| [orders.yaml](orders.yaml) | orders Deployment |
| [checkout.yaml](checkout.yaml) | checkout Deployment |
| [ui.yaml](ui.yaml) | ui Deployment |

Redis and RabbitMQ use the namespace default SA on purpose: they do not talk to AWS.
