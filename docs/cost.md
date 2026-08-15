# Cost and sizing decisions

The exam wants EKS, a NAT, an ALB, and two databases. That is **not** a free stack. We still pick the cheapest SKUs that can actually run the shop.

## Why these sizes

| Choice | Why | Advantage |
| --- | --- | --- |
| Nodes `t3.small` × 2 | `t3.micro` has 1 GiB RAM; Java services + Fluent Bit will Pending | Workloads schedule on first try |
| Nodes min 2 / max 3 (Cluster Autoscaler) | Bonus 5.3 needs a scale-up demo; cap at 3 so the bill cannot run away | Third node only while you demo |
| RDS `db.t3.micro`, 20 GiB, single-AZ | Smallest practical managed MySQL/Postgres | Free-tier class; still exceeds 750 h with *two* instances |
| DynamoDB on-demand | Exam traffic is tiny | No capacity planning |
| Lambda 128 MB | Only logs an object key | Minimal cost |
| Log retention 1 day | Graders do not need months of history | Less CloudWatch storage |
| Skip OpenSearch | Compose includes it; EKS nodes cannot spare the RAM | Keeps the cluster schedulable |
| One NAT | Exam cost guardrail | Roughly half the NAT bill vs two AZs each with NAT |

## Money that never goes away while the stack is up

- EKS control plane (~$0.10/hour)
- NAT Gateway hourly + data processing
- ALB (after stage 2)

**Destroy when you are not demoing.** Budget alerts (80% forecast / 100% actual) go to `lemikanemmanuel@gmail.com`.

CI also runs **Infracost** on the Terraform plan (not an AWS product — a plan-based cost estimate). See [terraform/ci.md](terraform/ci.md).

## Commands that stop the burn

```bash
# Empty assets bucket if destroy complains about objects
aws s3 rm s3://bedrock-assets-alt-soe-tin-025-0021 --recursive

cd terraform/envs
terraform destroy -var-file=prod.tfvars
```

Keep the **state bucket** until you are done with the project (see [terraform/bootstrap.md](terraform/bootstrap.md)).
