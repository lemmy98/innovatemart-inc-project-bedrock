# ingress/

## Aim

Give the shop a **stable public URL** on EKS without turning the UI Service into a cloud LoadBalancer.

Shoppers hit one Application Load Balancer. That ALB forwards to the `ui` pods. The UI then calls catalog / carts / checkout / orders **inside** the cluster.

## Why Ingress, not `Service type: LoadBalancer`

Upstream’s all-in-one YAML used `LoadBalancer` on `ui`. On EKS that would create a **Classic/NLB per Service** and skip the exam’s Ingress requirement.

We want:

| Choice | Why |
| --- | --- |
| `ingressClassName: alb` | AWS Load Balancer Controller owns this object |
| `scheme: internet-facing` | Graders (and you) open it from a browser |
| `target-type: ip` | Pods are the targets (VPC CNI); no extra NodePort hop |
| Health check `/actuator/health/liveness` | UI is Spring; don’t use `/` as the ALB health path |
| Backend `ui:80` | Matches [services/ui.yaml](../services/ui.yaml) (`ClusterIP`) |

One Ingress, one ALB, one hostname in `kubectl -n retail-app get ingress`.

## What “done” looks like

- Controller is running in `kube-system` (Terraform stage 2 installs it; YAML path assumes it exists).
- `ADDRESS` on the Ingress is an `*.elb.amazonaws.com` name.
- `http://<address>/` loads the shop on first bring-up.
- After that hostname exists, TLS/ACM (bonus 5.2) uses a real subdomain you control. Point DNS at the ALB, wait for the cert, then add `certificate-arn` + HTTPS listen-ports. Do not invent a fake hostname.

## Files

| File | Object |
| --- | --- |
| [ui.yaml](ui.yaml) | Ingress `ui` → Service `ui` port 80 |

No other public entrypoints. Catalog/orders/carts/checkout stay ClusterIP.

## Not in this folder

TLS/ACM is bonus 5.2 and is planned, not skipped. Sequence: ALB `ADDRESS` → your subdomain DNS → ACM issued → annotations on [ui.yaml](ui.yaml). Until then this Ingress is HTTP :80 only. See [docs/specs.md](../../docs/specs.md).
