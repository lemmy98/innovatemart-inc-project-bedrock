# ingress/

This is how I expose the shop. One **ALB** (Application Load Balancer) → `ui` pods.

Upstream used `Service type: LoadBalancer` on UI. On EKS that skips the Ingress requirement and costs extra, so I did not copy that.

Ingress `ui` → Service `ui:80`. The ALB controller comes from Terraform `enable_app_deploy`.

| Choice | Why I picked it |
| --- | --- |
| `ingressClassName: alb` | AWS Load Balancer Controller owns this object |
| `scheme: internet-facing` | Open it from a browser |
| `target-type: ip` | Pods are the targets (VPC CNI) |
| Health check `/actuator/health/liveness` | UI is Spring; do not use `/` |
| Backend `ui:80` | Matches [services/ui.yaml](../services/ui.yaml) |

`kubectl -n retail-app get ingress` should show an ALB address (`k8s-retailap-ui-….elb.amazonaws.com`).

TLS (bonus 5.2): host `lemikan-third-semester-exam-project.fyi`, ACM `certificate-arn`, ports 80+443, `ssl-redirect` to 443. I point Cloudflare **DNS-only** at the ALB. See [docs/app/bonuses.md](../../docs/app/bonuses.md).

File: [ui.yaml](ui.yaml). Catalog/orders/carts/checkout stay ClusterIP.
