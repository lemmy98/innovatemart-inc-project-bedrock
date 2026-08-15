# envs

This is where I wire modules. It does not declare VPC or RDS itself.

[stages](../../docs/terraform/stages.md) · [environments](../../docs/terraform/environments.md)

Stage 1 (`enable_app_deploy = false` in **tfvars**):

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file=prod.tfvars
```
