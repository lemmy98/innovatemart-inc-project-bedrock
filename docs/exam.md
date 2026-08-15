# Exam constraints

Tinyuka third semester — **Project Bedrock / InnovateMart**.

## Why names live in tfvars

Graders search for exact strings. If we hard-code them in `.tf` files, every rename means editing modules. Putting them in `prod.tfvars` / `dev.tfvars` means:

- one place to change
- modules stay reusable
- you can show “nothing exam-specific is buried in the module code”

Student ID `alt/soe/tin/025/0021` cannot be an S3 name (`/` and spaces are illegal), so Terraform turns it into `bedrock-assets-alt-soe-tin-025-0021`.

## Must match exactly

| Thing | Value |
| --- | --- |
| Region | `us-east-1` |
| VPC | `project-bedrock-vpc` |
| Cluster | `project-bedrock-cluster` |
| Namespace | `retail-app` |
| IAM user | `bedrock-dev-view` |
| Lambda | `bedrock-asset-processor` |
| Tag | `Project = tinyuka-2025-capstone` |
| Root outputs | only `cluster_endpoint`, `cluster_name`, `region`, `vpc_id`, `assets_bucket_name` |

## Core requirements (and how we meet them)

| Requirement | Our choice | Advantage |
| --- | --- | --- |
| Remote Terraform state | S3 + `use_lockfile = true` (Terraform ≥ 1.11) | No DynamoDB lock table to pay for or clean up |
| VPC with public + private | Two AZs, **one** NAT | Meets exam; keeps NAT cost to one gateway |
| Managed data stores | RDS MySQL (catalog), RDS Postgres (orders), DynamoDB (carts) | Matches the “override Compose” intent |
| Secrets | Secrets Manager + K8s secrets in stage 2 | Passwords never appear in root outputs |
| Developer access | IAM user + EKS Access Entry (`AmazonEKSViewPolicy` on `retail-app`) | Modern API auth; no fragile `aws-auth` edits |
| Logging | Control-plane logs + CloudWatch Observability add-on | Graders can see API and pod logs |
| Image upload path | Private S3 → Lambda | Exact log line `Image received: …` |
| Cost guardrail | AWS Budget ~$20 on the project tag | Email before the bill surprises you |
| App in `retail-app` | YAML/Kustomize (`k8s/`) **or** Helm stage 2 (exam allows both) | Same namespace and managed DBs either way |
| App + ALB on EKS | Helm stage 2 after nodes are Ready (`enable_app_deploy`) | Avoids half-broken first applies |
| Bonuses 5.1–5.5 | Helm, TLS-after-ALB, Cluster Autoscaler, NetworkPolicy, RDS backup + self-heal | Full extra credit; TLS waits on a real subdomain |

Full sizes: [specs.md](specs.md). Apply order: [terraform/stages.md](terraform/stages.md).
