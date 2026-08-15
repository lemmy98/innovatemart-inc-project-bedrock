# Start here

This repo is **Project Bedrock** (InnovateMart on EKS) for the Tinyuka exam.  
If you are the student handing this in, read this page first, then follow the links in order.

## What you are building

A retail shop on **Amazon EKS**, with:

- Terraform for the AWS cloud (VPC, EKS, RDS, DynamoDB, S3, Lambda, budget, IAM) — **no Helm until you flip a flag**
- Shop install: **YAML/Kustomize** (`k8s/`) **or** **Helm** (`helm/retail-store`, Terraform stage 2) — exam allows either
- GitHub Actions that **plan → you approve → apply** (and a separate **destroy** flow)
- **OIDC** into AWS (no long-lived AWS access keys in GitHub)

Exact exam names and rules: [exam.md](exam.md).

## Folder map (plain English)

| Folder | What it is |
| --- | --- |
| `terraform/bootstrap/` | One-time setup: state bucket + GitHub Actions IAM role |
| `terraform/envs/` | Main stack you plan/apply/destroy (uses `prod.tfvars`) |
| `terraform/modules/` | Building blocks (networking, eks, data, serverless, …) |
| `k8s/` | YAML/Kustomize shop install — namespace `retail-app`. See [k8s/README.md](../k8s/README.md) |
| `helm/retail-store/` | Helm umbrella for the same shop (Terraform stage 2) |
| `lambda/` | Code for `bedrock-asset-processor` |
| `.github/workflows/` | Apply + destroy pipelines |
| `docs/` | Why we chose things, how to run them, problems we fixed |

## Read in this order

1. [exam.md](exam.md) — names graders search for  
2. [architecture.md](architecture.md) — how pieces connect  
3. [specs.md](specs.md) / [cost.md](cost.md) — sizes and money  
4. [k8s/README.md](../k8s/README.md) — YAML layout and Secrets Manager  
5. [terraform/stages.md](terraform/stages.md) — AWS stage 0 → 1 → 2 (pay only when ready)  
6. [app/bonuses.md](app/bonuses.md) — Helm, TLS/ACM, autoscaler, NetworkPolicy, self-heal  
7. [terraform/ci.md](terraform/ci.md) — GitHub secrets + pipelines  
8. [modules/README.md](modules/README.md) — each module in one page  
9. [mortem/README.md](mortem/README.md) — problems we already solved (so you don’t repeat them)

## What is already done for you

- Terraform modules and exam tfvars  
- Bootstrap in AWS: state bucket + OIDC role `project-bedrock-github-actions`  
- CI on `dev`: apply and destroy both tested green, then the stack was destroyed again (so you are not paying for EKS right now)  
- Docs under `docs/`

## What you still do

1. Set GitHub secrets if you use CI ([terraform/ci.md](terraform/ci.md))  
2. Bring up AWS stage 1 (VPC/EKS/RDS — Helm still off)  
3. After EKS nodes are Ready, either `./scripts/k8s-up.sh` **or** flip `enable_app_deploy = true` for Helm/ALB  
4. After the ALB hostname exists, point your subdomain at it (Cloudflare DNS-only) and finish TLS — [app/bonuses.md](app/bonuses.md)  
5. Google Doc + `./scripts/export-grading.sh`  
6. Destroy AWS when demos are done (keep the state bucket)

## Two rules that save money and grades

- **Helm is not tied to Terraform until you flip the flag.** `enable_app_deploy` stays `false` until nodes are Ready.  
- **Destroy AWS when you are not demoing.** EKS + NAT cost money every hour.  
- **Apply the shop from `k8s/`** (`kubectl apply -k k8s/`) or Helm stage 2. Do not paste an upstream all-in-one YAML — that brings back in-cluster catalog/orders/carts DBs and fails the exam.

## If something breaks

Check [mortem/README.md](mortem/README.md) first. Most CI pain we already hit is written there in **Symptom → Cause → Fix → Lesson** form.
