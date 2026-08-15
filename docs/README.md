# Docs

I start at **[START_HERE.md](START_HERE.md)**. Code lives under `terraform/`, `k8s/`, `helm/`, and `lambda/`.

## Where I look

| Goal | Page |
| --- | --- |
| My onboarding | [START_HERE.md](START_HERE.md) |
| Exact exam names and rules | [exam.md](exam.md) |
| How traffic and data flow | [architecture.md](architecture.md) |
| Resource sizes and cost | [cost.md](cost.md) / [specs.md](specs.md) |
| Work phases | [phases.md](phases.md) |
| Shop YAML | [k8s/README.md](../k8s/README.md) |
| Apply order (stage 0 → 1 → 2) | [terraform/stages.md](terraform/stages.md) |
| CI plan → approve → apply / destroy | [terraform/ci.md](terraform/ci.md) |
| Failures I already hit | [mortem/README.md](mortem/README.md) |
| Each Terraform module | [modules/README.md](modules/README.md) |
| Official sample app vs my deploy | [app/upstream.md](app/upstream.md) |
| Bonuses 5.1–5.5 | [app/bonuses.md](app/bonuses.md) |

## Where I am

- Stage 0 (state bucket + GitHub **OIDC** role) exists in AWS. OIDC = GitHub Actions logs into AWS with a role, not access keys.
- I do **not** leave stage 1/2 running. I destroy when I’m not demoing.
- `enable_app_deploy` stays **`false`** until EKS nodes are Ready.
- Next for me: GitHub secrets if needed → stage 1 apply → YAML (`k8s/`) or Helm → grading docs.
