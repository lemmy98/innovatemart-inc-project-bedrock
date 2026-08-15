# bootstrap

Creates the state bucket and the GitHub Actions **OIDC** role (GitHub logs into AWS with a role, not access keys). Local state on purpose — I run this before remote state exists.

[docs/terraform/bootstrap.md](../../docs/terraform/bootstrap.md)

```bash
terraform init
terraform apply -var-file=prod.tfvars
terraform output -raw github_actions_role_arn   # → GitHub secret AWS_ROLE_ARN
```
