# Project Bedrock

InnovateMart on Amazon EKS for the Tinyuka **Project Bedrock** exam, using the [AWS retail-store sample app](https://github.com/aws-containers/retail-store-sample-app) pinned at **v1.6.2**.

**If you are submitting this assignment, start here → [docs/START_HERE.md](docs/START_HERE.md).**

Work on the `dev` branch while testing. `main` and `dev` should stay aligned after merges.

## What lives where

| Path | Purpose |
| --- | --- |
| [docs/](docs/) | Human docs: exam rules, architecture, stages, CI, mortems |
| [terraform/bootstrap/](terraform/bootstrap/) | State bucket + GitHub Actions OIDC role (one-time) |
| [terraform/envs/](terraform/envs/) | Main Terraform stack (`prod.tfvars`) |
| [terraform/modules/](terraform/modules/) | networking, eks, data, serverless, budget, iam-developer, k8s-apps |
| [k8s/](k8s/) | Shop YAML/Kustomize (namespace `retail-app`) |
| [helm/retail-store/](helm/retail-store/) | Shop Helm chart (stage 2) |
| [lambda/](lambda/) | S3 image processor |
| [.github/workflows/](.github/workflows/) | Apply + destroy pipelines |

## Graders look for

`us-east-1`, `project-bedrock-vpc`, `project-bedrock-cluster`, namespace `retail-app`, user `bedrock-dev-view`, lambda `bedrock-asset-processor`, tag `Project=tinyuka-2025-capstone`, and **exactly five** root outputs: `cluster_endpoint`, `cluster_name`, `region`, `vpc_id`, `assets_bucket_name`.

Details: [docs/exam.md](docs/exam.md).

## Bring-up (short version)

Bootstrap (if the state bucket / OIDC role are not there yet):

```bash
cd terraform/bootstrap
terraform init
terraform apply -var-file=prod.tfvars
terraform output -raw backend_hcl > ../envs/backend.hcl
terraform output -raw github_actions_role_arn   # → GitHub secret AWS_ROLE_ARN
```

Stage 1 (cloud only; Helm off — `enable_app_deploy = false`):

```bash
cd terraform/envs
terraform init -backend-config=backend.hcl
terraform apply -var-file=prod.tfvars
```

Or use GitHub Actions on `dev`: push Terraform changes → review plan → comment **`approve`** on the Issue.  
Destroy the same way with the **Terraform Destroy** workflow (`confirm=destroy`). See [docs/terraform/ci.md](docs/terraform/ci.md).

Shop on EKS (after nodes are Ready): YAML `./scripts/k8s-up.sh` **or** set `enable_app_deploy = true` and apply again. See [k8s/README.md](k8s/README.md).

## Specs in one line

2 × `t3.small` nodes, EKS **1.34**, RDS `db.t3.micro` × 2, DynamoDB on-demand, Lambda 128 MB, budget **$20** → `lemikanemmanuel@gmail.com`.  
Full table: [docs/specs.md](docs/specs.md).

## Important

- Shop YAML is **`k8s/`** (`kubectl apply -k k8s/`) — not an upstream all-in-one dump.  
- Prefer **OIDC** (`AWS_ROLE_ARN`); do not put AWS access keys in GitHub secrets.  
- Destroy when you are not demoing — EKS and NAT keep billing.
