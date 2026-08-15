# envs

Wires modules. Does not declare VPC or RDS itself.

[docs/terraform/stages.md](../../docs/terraform/stages.md) · [docs/terraform/environments.md](../../docs/terraform/environments.md)

Stage 1 (`enable_app_deploy = false`):

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file=prod.tfvars
```
