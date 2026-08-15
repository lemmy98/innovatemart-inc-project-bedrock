# Environments

## Why two tfvars files

`prod.tfvars` is what you grade with. `dev.tfvars` is the same **exam names** with a lower budget ($15 vs $20) for cheaper experiments.

You cannot run both stacks in one account at once — names like `project-bedrock-cluster` are unique.

## Why sizes are not in `.tf` files

Modules should describe *shape*. Tfvars describe *this exam’s numbers*. That makes reviews easier: open `prod.tfvars` and you see every grader-facing knob.

## Important flags

| Variable | Prod value | Meaning |
| --- | --- | --- |
| `enable_app_deploy` | `true` after stage 1 | ALB controller + CA + carts IRSA (shop = K8s Deploy workflow) |
| `enable_network_policies` | `false` | NPs live in `k8s/networkpolicies/` |
| `enable_cluster_autoscaler` | `true` | Bonus 5.3 |
| `ui_hostname` / `acm_certificate_arn` | `lemikan-third-semester-exam-project.fyi` + issued ACM ARN | Bonus 5.2; Ingress HTTPS + SSL redirect |
| `install_helm_on_nodes` | `true` | Helm binary via cloud-init |
| `budget_notification_email` | `lemikanemmanuel@gmail.com` | Where AWS Budget writes |

Full table of sizes: [../specs.md](../specs.md).
