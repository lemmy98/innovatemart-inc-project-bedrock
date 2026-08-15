# Architecture

## What this represents

InnovateMart’s shop runs as microservices on EKS. Shoppers hit an Application Load Balancer (stage 2). The `ui` pod talks to catalog, carts, checkout, and orders. Catalog and orders use **managed RDS** in private subnets. Carts uses **DynamoDB** through IRSA (no static AWS keys in the pod). Redis and RabbitMQ stay **in the cluster** because the exam allows that and it keeps cost down.

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
