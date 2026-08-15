# Resource specs (what we deploy)

All sizes live in `terraform/envs/prod.tfvars` (grading) and `dev.tfvars` (same names, $15 budget). Change them there — not inside module `.tf` files.

## Cloud (stage 1)

| Resource | Spec | Why this size |
| --- | --- | --- |
| Region | `us-east-1` | Exam requires it |
| VPC | `project-bedrock-vpc`, `10.42.0.0/16`, 2 AZs | Exam name; two AZs for basic resilience |
| NAT | **1** gateway | Exam cost rule; private nodes still pull images |
| EKS | `project-bedrock-cluster`, Kubernetes **1.34** | Oldest version in EKS *standard* support (Aug 2026) |
| Nodes | **2 × `t3.small`**, 20 GiB disk, private subnets | `t3.micro` (1 GiB) cannot fit Java pods + Fluent Bit |
| Node scaling | min **2** / desired **2** / max **3** | Cluster Autoscaler (bonus 5.3); third node only during the scale-up demo |
| Helm on nodes | cloud-init installs Helm CLI | Exam wording; charts still installed by Terraform in stage 2 |
| Catalog DB | RDS MySQL **8.0**, `db.t3.micro`, 20 GiB, private | Exam override of Compose MariaDB |
| Orders DB | RDS PostgreSQL **16**, user `dbadmin`, `db.t3.micro`, 20 GiB | `admin` is reserved on RDS |
| Carts | DynamoDB `bedrock-carts`, on-demand, GSI `idx_global_customerId` | What the Java cart service expects |
| Assets | S3 `bedrock-assets-alt-soe-tin-025-0021` (private) | Student id slug (no `/` or spaces) |
| Lambda | `bedrock-asset-processor`, Python 3.12, **128 MB**, 10 s | Logs `Image received: <filename>` |
| IAM user | `bedrock-dev-view` + ReadOnlyAccess + `s3:PutObject` + Deny `s3:DeleteObject` | Graders upload; delete demo shows AccessDenied |
| Budget | **$20**/month (prod), email `lemikanemmanuel@gmail.com` | Tag filter `Project=tinyuka-2025-capstone` |
| Logs | Control-plane + Observability addon, **1 day** retention | Enough for grading, cheap to keep |

## App pods (stage 2 — Helm)

Pinned chart version **1.6.2**. In-cluster MySQL / Postgres / DynamoDB Local are **off**. Redis and RabbitMQ stay as pods (exam allows that).

| Service | Replicas | CPU request | Memory request | Memory limit |
| --- | --- | --- | --- | --- |
| catalog | 1 | 50m | 128Mi | 256Mi |
| carts | 1 | 50m | 256Mi | 384Mi |
| orders | 1 | 50m | 256Mi | 384Mi |
| checkout | 1 | 50m | 128Mi | 256Mi |
| ui | 1 | 50m | 256Mi | 384Mi |
| AWS LB Controller | 1 | 50m | 64Mi | (chart default) |

UI Ingress: internet-facing ALB, target type `ip`, health check `/actuator/health/liveness`. HTTP :80 first; HTTPS after a real subdomain + ACM (bonus 5.2).

## What we skip vs what waits on AWS

| Item | Status |
| --- | --- |
| OpenSearch | Skip — too much RAM for `t3.small` nodes |
| In-cluster MySQL / Postgres / DynamoDB Local on EKS | Skip — exam wants RDS + DynamoDB; `k8s/` points at managed data |
| Cluster Autoscaler (bonus 5.3) | In scope — min 2 / max 3 nodes; scale-up demo after the shop is up |
| TLS / ACM (bonus 5.2) | In scope — HTTP first. After the ALB hostname exists, point a real subdomain at it (ACM cannot validate nip.io) |

## Root outputs (exactly five)

`cluster_endpoint`, `cluster_name`, `region`, `vpc_id`, `assets_bucket_name`

No passwords or access keys in root outputs. Use `scripts/export-grading.sh` for a safe `grading.json`.
