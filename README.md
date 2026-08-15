# Project Bedrock

This is my Tinyuka exam shop: InnovateMart on **Amazon EKS** (AWS runs the Kubernetes control plane). I use the [AWS retail-store sample](https://github.com/aws-containers/retail-store-sample-app) **v1.6.2**.

I start from [docs/START_HERE.md](docs/START_HERE.md). I work on `dev` while testing and keep `main` aligned after merges.

## Words I use here

| Term | Meaning |
| --- | --- |
| **EKS** | Amazon Elastic Kubernetes Service — AWS runs the Kubernetes control plane |
| **ALB** | Application Load Balancer — public HTTPS entry to my shop UI |
| **OIDC** | OpenID Connect — GitHub Actions logs into AWS with a role, not access keys |
| **Helm** | Installer for Kubernetes apps (the other shop path besides YAML) |
| **tfvars** | Terraform variables file — exam names and sizes live here, not in `.tf` |

## Where I put things

| Path | Purpose |
| --- | --- |
| [docs/](docs/) | Exam rules, architecture, stages, CI, mortems |
| [terraform/bootstrap/](terraform/bootstrap/) | State bucket + GitHub Actions OIDC role (one-time) |
| [terraform/envs/](terraform/envs/) | Main Terraform stack (`prod.tfvars`) |
| [terraform/modules/](terraform/modules/) | networking, eks, data, serverless, budget, iam-developer, k8s-apps |
| [k8s/](k8s/) | Shop YAML (namespace `retail-app`) |
| [helm/retail-store/](helm/retail-store/) | Shop Helm chart (bonus 5.1) |
| [lambda/](lambda/) | S3 image processor |
| [.github/workflows/](.github/workflows/) | Apply + destroy pipelines |

## Names I must not forget

`us-east-1`, `project-bedrock-vpc`, `project-bedrock-cluster`, namespace `retail-app`, user `bedrock-dev-view`, lambda `bedrock-asset-processor`, tag `Project=tinyuka-2025-capstone`, and **exactly five** root outputs: `cluster_endpoint`, `cluster_name`, `region`, `vpc_id`, `assets_bucket_name`.

Details: [docs/exam.md](docs/exam.md).

## How I bring the shop up

Bootstrap (only if the state bucket / OIDC role are missing):

```bash
cd terraform/bootstrap
terraform init
terraform apply -var-file=prod.tfvars
terraform output -raw backend_hcl > ../envs/backend.hcl
terraform output -raw github_actions_role_arn   # → GitHub secret AWS_ROLE_ARN
```

Stage 1 — cloud only (`enable_app_deploy = false` in tfvars):

```bash
cd terraform/envs
terraform init -backend-config=backend.hcl
terraform apply -var-file=prod.tfvars
```

Or I use GitHub Actions on `dev`: push Terraform → review the plan → comment **`approve`** on the Issue. I destroy with **Terraform Destroy** (`confirm=destroy`). See [docs/terraform/ci.md](docs/terraform/ci.md).

After nodes are Ready: I set `enable_app_deploy = true` and apply again (ALB controller + carts IRSA). Then I install the shop with **one** path: `./scripts/k8s-up.sh` **or** `./scripts/helm-up.sh`. See [k8s/README.md](k8s/README.md).

## Specs I chose

2 × `t3.small` nodes, EKS **1.34**, RDS `db.t3.micro` × 2, DynamoDB on-demand, Lambda 128 MB, budget **$20** → `lemikanemmanuel@gmail.com`. Full table: [docs/specs.md](docs/specs.md).

## What I must not forget

- Shop YAML is **`k8s/`** (`kubectl apply -k k8s/`). I never apply the vendor `kubernetes.yaml` — it starts in-cluster databases and fails the exam.
- I prefer **OIDC** (`AWS_ROLE_ARN`). I do not put AWS access keys in GitHub secrets.
- I destroy when I’m not demoing. EKS and NAT keep billing.
