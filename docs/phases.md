# Project phases

Use this as your checklist. Skip anything already done in AWS/GitHub.

## Already done in the repo

| Piece | Status |
| --- | --- |
| Modules, tfvars, Helm chart, Lambda | In git on `dev` / `main` |
| Docs (exam, architecture, stages, CI, mortems) | Under `docs/` — start at [START_HERE.md](START_HERE.md) |
| Stage 0 state bucket | `bedrock-assets-alt-soe-tin-025-0021` |
| GitHub Actions OIDC role | `project-bedrock-github-actions` (bootstrap) |
| Apply + destroy pipelines | Tested; stack not left running |

`enable_app_deploy` stays **`false`** until EKS nodes are Ready.

---

## Phase 1 — Secrets and reading (no big AWS bill)

- [ ] Read [START_HERE.md](START_HERE.md) and [exam.md](exam.md)  
- [ ] Confirm GitHub secrets: `TF_STATE_BUCKET`, `AWS_ROLE_ARN` (from bootstrap), optional `INFRACOST_API_KEY` — see [terraform/ci.md](terraform/ci.md)  
- [ ] Skim [k8s/README.md](../k8s/README.md) so the YAML vs Helm choice is clear  
- [ ] Skim [mortem/README.md](mortem/README.md) so CI surprises are familiar  
- [ ] Outline the Google Doc from the module “Why” tables  

## Phase 2 — Stage 1 apply (cloud only, no shop UI yet)

Creates VPC, EKS, RDS, DynamoDB, S3, Lambda, budget, IAM user. **Money starts here.**

```bash
cd terraform/envs
terraform apply -var-file=prod.tfvars
```

Or push to `dev` and comment **`approve`** on the CI Issue.

Quick checks:

```bash
aws s3 cp /tmp/demo.jpg s3://bedrock-assets-alt-soe-tin-025-0021/demo.jpg
aws logs tail /aws/lambda/bedrock-asset-processor --since 5m
aws iam get-user --user-name bedrock-dev-view
aws dynamodb describe-table --table-name bedrock-carts
./scripts/export-grading.sh
```

Save developer access keys from Terraform state into the **private** Google Doc — never commit them.

## Phase 3 — Shop + ALB on EKS

Only after `kubectl get nodes` on EKS shows Ready. Pick **one**:

**A. YAML / Kustomize**

```bash
./scripts/k8s-sync-secrets.sh
kubectl apply -k k8s/          # or ./scripts/k8s-up.sh
kubectl -n retail-app get ingress
```

**B. Helm via Terraform**

1. Set `enable_app_deploy = true` in `prod.tfvars`  
2. Apply again (local or CI) — managed RDS/DynamoDB, secrets from Secrets Manager, ALB  
3. `kubectl get ingress -n retail-app` → shop URL  

Do not run A and B on the same cluster.

Bonuses: follow [app/bonuses.md](app/bonuses.md). NetworkPolicies are already in `k8s/networkpolicies/` and Terraform. Cluster Autoscaler scale-up demo after nodes are Ready. TLS/ACM after the Ingress has an ALB hostname and you point a real subdomain at it.

## Phase 4 — Hand-in

- Live URL, screenshots, `grading.json` (five outputs only)  
- Google Doc: decisions, destroy steps, cost notes, credentials  
- Tag check: `Project=tinyuka-2025-capstone`  

## Phase 5 — Tear down

Prefer the **Terraform Destroy** workflow (`confirm=destroy`), or:

```bash
aws s3 rm s3://bedrock-assets-alt-soe-tin-025-0021 --recursive || true
cd terraform/envs && terraform destroy -var-file=prod.tfvars
```

Keep the **state bucket** and OIDC role until the course is fully finished.
