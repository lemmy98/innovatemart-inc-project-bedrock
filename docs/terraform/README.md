# Terraform

| Path | Role |
| --- | --- |
| `terraform/bootstrap/` | State bucket + GitHub **OIDC** role. Uses local state until the bucket exists. |
| `terraform/envs/` | Root module. The one place I `plan` / `apply` the stack. |
| `terraform/modules/*` | One concern each. |

`envs` does not invent sizes. It reads **tfvars** (Terraform variables) and passes them into modules.

Backend: S3 + `use_lockfile = true`. [bootstrap.md](bootstrap.md) · [stages.md](stages.md)

CI: plan → Issue `approve` → apply. [ci.md](ci.md)

Helm provider is **v3**: `kubernetes = local.helm_kubernetes` (not a nested `kubernetes { }` block). Why: [mortem/helm-provider.md](../mortem/helm-provider.md).

If the state bucket exists and `backend.hcl` is present:

```bash
cd terraform/envs
terraform init -backend-config=backend.hcl
terraform apply -var-file=prod.tfvars
```
