# Terraform

## Layout (and why)

| Path | Role | Why split |
| --- | --- | --- |
| `terraform/bootstrap/` | Creates the state bucket | Must use local state until the bucket exists |
| `terraform/envs/` | Root module: wires everything | One place to `plan` / `apply` the real stack |
| `terraform/modules/*` | One concern each | Smaller reviews; clearer ownership |

`envs` does not invent resource sizes. It reads `prod.tfvars` / `dev.tfvars` and passes values into modules.

## Backend

S3 + `use_lockfile = true`. See [bootstrap.md](bootstrap.md) and [stages.md](stages.md).

## CI

Plan and apply live in one workflow with a manual Issue approval before apply. See [ci.md](ci.md).

## Provider note (Helm)

We use Helm provider **v3**. Kubernetes connection settings use attribute form:

```hcl
provider "helm" {
  kubernetes = local.helm_kubernetes
}
```

(not a nested `kubernetes { }` block — that was Helm provider v2).

## Next command

If the state bucket already exists and `backend.hcl` is present:

```bash
cd terraform/envs
terraform init -backend-config=backend.hcl
terraform apply -var-file=prod.tfvars
```
