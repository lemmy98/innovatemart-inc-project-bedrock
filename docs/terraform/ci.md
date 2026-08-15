# GitHub Actions (Terraform)

You use these workflows to change AWS **without** pasting access keys into GitHub.

| Workflow | File | What it does |
| --- | --- | --- |
| **Terraform** | [terraform.yml](../../.github/workflows/terraform.yml) | Plan → you approve → apply (`terraform/envs`) |
| **Terraform Destroy** | [terraform-destroy.yml](../../.github/workflows/terraform-destroy.yml) | Destroy-plan → you approve → destroy envs (keeps bootstrap) |
| **Terraform Bootstrap** | [terraform-bootstrap.yml](../../.github/workflows/terraform-bootstrap.yml) | Plan → approve → apply stage 0 (state bucket + OIDC role) |
| **Terraform Bootstrap Destroy** | [terraform-bootstrap-destroy.yml](../../.github/workflows/terraform-bootstrap-destroy.yml) | Destroy bootstrap **after** envs is gone (`confirm=destroy-bootstrap`) |

Full student path: [START_HERE.md](../START_HERE.md).

## Testing mode (current)

Pipelines are gated to **`dev`** while we test:

| How you start it | What runs |
| --- | --- |
| Pull request into `dev` | Plan only (+ Infracost if the key exists) |
| Push to `dev` (Terraform-related paths) | Plan → GitHub Issue → after **`approve`**, apply |
| Actions → **Terraform Destroy** (type `destroy`) | Destroy-plan → Issue → after **`approve`**, destroy |

Later you can switch those branch checks to **`main` only**.

Comment **`deny`** on the Issue to cancel.  
Destroy removes the main stack only. It **keeps** the state bucket and the GitHub OIDC role (bootstrap).

## Login to AWS: OIDC (no access keys)

Exam prefers short-lived login from GitHub → AWS.

```bash
cd terraform/bootstrap
terraform output -raw github_actions_role_arn
```

Put that value in secret **`AWS_ROLE_ARN`**.  
Do **not** add `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`.

## Infracost (optional cost table)

Not an AWS product and **not required** for the exam. It estimates monthly cost from the plan.  
Free key: [dashboard.infracost.io](https://dashboard.infracost.io) → secret `INFRACOST_API_KEY`.  
If missing, deploy still works.

## Secrets checklist

| Name | Required? | Value |
| --- | --- | --- |
| `TF_STATE_BUCKET` | yes | `bedrock-assets-alt-soe-tin-025-0021` |
| `AWS_ROLE_ARN` | yes | bootstrap output `github_actions_role_arn` |
| `AWS_REGION` | no | defaults to `us-east-1` |
| `INFRACOST_API_KEY` | no | from Infracost Cloud |

Approver GitHub user in the YAML: `lemmy98` (change `approvers:` if needed).

## Run destroy from the CLI

```bash
gh workflow run terraform-destroy.yml --ref dev -f confirm=destroy
```

Then open the approval Issue and comment **`approve`**.
