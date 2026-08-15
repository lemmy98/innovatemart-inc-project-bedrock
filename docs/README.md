# Docs

Written so **you** (the student) can understand the project without guessing.

Start: **[START_HERE.md](START_HERE.md)**.

Code lives under `terraform/`, `k8s/`, `helm/`, and `lambda/`. Read the docs before you change sizes or flip flags.

## Where to start

| Goal | Page |
| --- | --- |
| **Student onboarding** | [START_HERE.md](START_HERE.md) |
| Exact exam names and rules | [exam.md](exam.md) |
| How traffic and data flow | [architecture.md](architecture.md) |
| Resource sizes and cost choices | [cost.md](cost.md) / [specs.md](specs.md) |
| Work phases (what to do next) | [phases.md](phases.md) |
| Shop YAML / Kustomize | [k8s/README.md](../k8s/README.md) |
| Apply order (stage 0 → 1 → 2) | [terraform/stages.md](terraform/stages.md) |
| CI plan → approve → apply / destroy | [terraform/ci.md](terraform/ci.md) |
| Problems we hit and how we fixed them | [mortem/README.md](mortem/README.md) |
| Each Terraform module | [modules/README.md](modules/README.md) |
| Official sample app vs our deploy | [app/upstream.md](app/upstream.md) |
| Bonuses 5.1–5.5 (Helm, TLS, CA, NP, self-heal) | [app/bonuses.md](app/bonuses.md) |

## How this project is shaped

1. **Exam names stay in tfvars**, not hard-coded in `.tf` files — one place to change.
2. **Bring the cloud up in stages.** State → VPC/EKS/DBs → Helm/ALB. Helm on a cold cluster usually fails.
3. **Smallest sizes that still run the Java shop.** EKS + NAT always cost money.
4. **Apply the shop from `k8s/`** (or Helm stage 2). An upstream all-in-one YAML recreates in-cluster databases and breaks the managed-DB requirement.

## Current status (honest)

- Stage 0 (state bucket + GitHub OIDC role) exists in AWS.  
- Stage 1/2 are **not** left running by default — CI applied and destroyed during testing so the bill stops.  
- `enable_app_deploy` stays **`false`** until nodes are Ready and you choose stage 2.  
- Next student action: set GitHub secrets if needed, then stage 1 apply (local or CI), then YAML (`k8s/`) or Helm stage 2, then Google Doc / grading deliverables.
