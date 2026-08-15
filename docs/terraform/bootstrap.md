# Stage 0: remote state + GitHub Actions OIDC

## Why we do this first

1. A `terraform.tfstate` only on your laptop is easy to lose and impossible for CI to share.
2. GitHub Actions needs an IAM role **before** it can plan/apply `terraform/envs` — so the OIDC provider + role live here with the bucket (same chicken-and-egg as state).

Exam: **OIDC preferred**, access keys are the fallback we avoid.

## What we built

| Piece | Choice | Advantage |
| --- | --- | --- |
| Backend | S3 bucket | Simple, durable, versioned |
| Locking | `use_lockfile = true` (Terraform ≥ 1.11) | No DynamoDB lock table |
| Security | SSE-S3, Block Public Access, BucketOwnerEnforced | Default-deny public access |
| Name | `bedrock-assets-alt-soe-tin-025-0021` | Tied to student id |
| CI auth | IAM OIDC provider + role `project-bedrock-github-actions` | No long-lived keys in GitHub |
| Trust `sub` | Immutable `ORG@id/REPO@id` (plus legacy name form) | Required for repos created after 2026-07-15 |

Bootstrap uses **local** state on the first laptop apply (bucket cannot store its own creation). After the bucket exists, migrate state into S3 so CI can manage bootstrap:

```bash
cd terraform/bootstrap
cat > backend.hcl <<EOF
bucket       = "bedrock-assets-alt-soe-tin-025-0021"
key          = "tinyuka/bootstrap/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
EOF
terraform init -migrate-state -backend-config=backend.hcl
```

Then use Actions → **Terraform Bootstrap** / **Terraform Bootstrap Destroy**.

## Commands

```bash
cd terraform/bootstrap
terraform init
terraform apply -var-file=prod.tfvars
terraform output -raw backend_hcl > ../envs/backend.hcl
terraform output -raw github_actions_role_arn
```

Put the role ARN into GitHub secret **`AWS_ROLE_ARN`**. Put the bucket name into **`TF_STATE_BUCKET`**.

Then:

```bash
cd ../envs
terraform init -backend-config=backend.hcl
```

`backend.hcl` is gitignored so account-specific bucket config never lands in git.

## Do not destroy casually

If you delete this bucket while `envs` still has resources, Terraform forgets what it created and cleanup becomes manual console work. Destroy `envs` first. You can keep the OIDC role if CI still needs it.
