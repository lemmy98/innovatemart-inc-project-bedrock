# Bring-up order (stages)

## Why stages exist

If you create the cluster and install Helm charts in one apply, Terraform’s Helm provider often tries to talk to the API server before nodes are Ready. You get a half-created cluster and a painful cleanup.

So we split the work:

| Stage | What | Flag |
| --- | --- | --- |
| 0 | S3 bucket for Terraform state | bootstrap apply (once) |
| 1 | VPC, EKS, RDS, DynamoDB, IAM, S3/Lambda, budget | `enable_app_deploy = false` |
| 2 | Helm apps + ALB on **EKS** (or apply `k8s/` instead) | `enable_app_deploy = true` (only after Ready nodes) |

## Prerequisites

- AWS credentials in the environment (`aws sts get-caller-identity` works)
- Terraform ≥ 1.11
- Optional later: `kubectl`, `helm`

## Stage 0 — state bucket (once)

**Why:** Exam rejects laptop-only state. S3 versioning + encryption + native lock files (`use_lockfile = true`) give remote state without a DynamoDB lock table.

```bash
cd terraform/bootstrap
terraform init
terraform apply -var-file=prod.tfvars

# Write backend config (gitignored)
terraform output -raw backend_hcl > ../envs/backend.hcl
```

Bucket name: `bedrock-assets-alt-soe-tin-025-0021`.  
Details: [bootstrap.md](bootstrap.md).

## Stage 1 — cloud resources (do this next)

**Why:** Prove networking, cluster, and databases before touching Helm.

```bash
cd terraform/envs
terraform init -backend-config=backend.hcl
terraform plan  -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

Confirm:

```bash
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster
kubectl get nodes
# expect 2 nodes, STATUS Ready

aws rds describe-db-instances \
  --query 'DBInstances[?contains(DBInstanceIdentifier,`bedrock`)].{id:DBInstanceIdentifier,status:DBInstanceStatus}' \
  --output table
```

Safe grading outputs:

```bash
./scripts/export-grading.sh
# writes grading.json with the five allowed outputs only
```

## Stage 2 — shop + ALB on EKS (after Ready nodes)

**Why:** Helm on EKS needs a working API **and** managed DBs. Flip one flag and re-apply. YAML path: [k8s/README.md](../../k8s/README.md) (`./scripts/k8s-up.sh`) — do not combine with this flag.

1. In `terraform/envs/prod.tfvars` set `enable_app_deploy = true`
2. Apply again:

```bash
cd terraform/envs
terraform apply -var-file=prod.tfvars
```

3. Find the public URL:

```bash
kubectl get ingress -n retail-app
# ADDRESS column is the ALB hostname — open http://<address>/
```

**Do not** also run `helm install` from the umbrella chart while Terraform manages releases — pick one path.

## Destroy

```bash
aws s3 rm s3://bedrock-assets-alt-soe-tin-025-0021 --recursive || true
cd terraform/envs
terraform destroy -var-file=prod.tfvars
```

Destroy bootstrap (state bucket) only after `envs` is gone.
