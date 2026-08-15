# Architecture

## What this represents

InnovateMart’s shop runs as microservices on EKS. Shoppers hit an Application Load Balancer (stage 2). The `ui` pod talks to catalog, carts, checkout, and orders. Catalog and orders use **managed RDS** in private subnets. Carts uses **DynamoDB** through IRSA (no static AWS keys in the pod). Redis and RabbitMQ stay **in the cluster** because the exam allows that and it keeps cost down.

![Project Bedrock architecture diagram: shoppers reach an ALB in a public subnet, which routes to the ui pod on private EKS nodes; ui fans out to catalog, carts, checkout, and orders; catalog and orders use RDS MySQL and RDS Postgres in private subnets, carts uses DynamoDB via IRSA, checkout uses in-cluster Redis, orders uses in-cluster RabbitMQ; a separate S3-to-Lambda-to-CloudWatch flow processes uploaded images; an IAM developer user gets read-only console access plus a namespace-scoped EKS Access Entry.](architecture-diagram.svg)

<details>
<summary>Text-only fallback (same information, no image)</summary>

```
                         internet
                             |
                        IGW + ALB          ← stage 2 (Helm)
                             |
               +-------------vpc--------------+
               | public: ALB, one NAT         |
               | private: EKS nodes, RDS      |
               +------------------------------+
                             |
              S3 assets → Lambda → CloudWatch
```

</details>

**EKS public endpoint access:** the API server's public endpoint allow-list
is an explicit Terraform variable (`admin_access_cidrs` in `terraform/envs`)
rather than an implicit default, currently set to `["0.0.0.0/0"]`. This isn't
an oversight: every pipeline that talks to the cluster (the `k8s-apps` Helm
releases inside `terraform apply`, plus `helm-deploy.yml`, `k8s-deploy.yml`,
`networkpolicies.yml`, `cluster-verify.yml`) runs on GitHub-hosted runners
with large, dynamic IP ranges, and EKS endpoint CIDR updates are too slow
and too serialized for per-run self-allowlisting to work. IAM and EKS Access
Entries remain the real authorization boundary regardless of network
reachability. To tighten this: stand up a self-hosted Actions runner inside
the VPC, then set `admin_access_cidrs` to just its CIDR plus any operator
workstation IPs — see `terraform/modules/eks/variables.tf`.

## Deployment path: Helm is authoritative

The app supports two ways to deploy the shop manifests: raw Kustomize
(`kubectl apply -k k8s/`, satisfying core requirement 4.2's "standard
Kubernetes manifests" option) and the Helm chart under `helm/retail-store/`
(bonus 5.1). Both are kept in the repo and both are individually valid, but
**only one can own the live Deployments/StatefulSet at a time**:

- Kubernetes forbids changing `spec.selector` on an existing
  Deployment/StatefulSet, so whichever tool created an object first "owns"
  its selector going forward — patching over it with the other tool's
  differently-labeled manifest fails outright.
- Helm additionally requires the label `app.kubernetes.io/managed-by: Helm`
  (plus matching `meta.helm.sh/release-name`/`release-namespace`
  annotations) on anything it manages. Kustomize's manifests here set
  `managed-by: kustomize`. Whichever pipeline applies last "wins" that
  label, and the *other* pipeline's own consistency check then fails on
  its next run.

**Helm is the one actually running the live app** (`helm-deploy.yml`,
proven green including a smoke test against the ALB). `k8s-deploy.yml`
(raw Kustomize) is kept as a manual-only (`workflow_dispatch`) reference
path — its manifests are label-aligned with Helm's convention and pass
`kustomize build` + a dry-run apply, but it does not run automatically on
push, specifically to avoid fighting Helm for ownership of the same live
objects. `networkpolicies.yml` is unaffected by any of this and stays
active on every push — NetworkPolicies aren't part of the Helm release
(both `helm-up.sh` and `networkpolicies.yml` apply
`k8s/networkpolicies/**` the same plain `kubectl apply -f` way), so there's
no ownership conflict there.

## Why this shape

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Private nodes + one NAT | Nodes should not need public IPs; still need outbound pulls | Safer default; one NAT satisfies the exam cost rule |
| Managed RDS/DynamoDB | Exam asks to override Compose’s local DBs | Stable data layer; easier for graders to inspect |
| Redis/RabbitMQ as pods | Allowed by exam; MQ/Redis as managed services would cost more | Smaller bill; same app wiring as upstream charts |
| ALB via AWS Load Balancer Controller | Exam wants Ingress on EKS | Standard AWS pattern; gets a public URL for the shop |
| Stage 1 without Helm | Helm needs a live API server and Ready nodes | First apply creates cloud only; fewer failed half-stacks |

## Stages in one sentence

- **Stage 0:** bucket that stores Terraform state  
- **Stage 1:** VPC, EKS, databases, IAM, S3/Lambda, budget  
- **Stage 2:** namespace, secrets, LB controller, five retail charts, ALB  

See [specs.md](specs.md) for sizes and [terraform/stages.md](terraform/stages.md) for commands.
