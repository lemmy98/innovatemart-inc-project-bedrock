# bootstrap

Creates the state bucket **and** the GitHub Actions OIDC role. Local state on purpose.

[docs/terraform/bootstrap.md](../../docs/terraform/bootstrap.md)

```bash
terraform init
terraform apply -var-file=prod.tfvars
terraform output -raw github_actions_role_arn   # → GitHub secret AWS_ROLE_ARN
```
