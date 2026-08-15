# networking

## What it is

VPC `project-bedrock-vpc` (`10.42.0.0/16`) with two public and two private subnets across `us-east-1a` / `us-east-1b`, one Internet Gateway, and **one** NAT Gateway.

## Why

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Public + private | ALB needs public subnets; nodes/RDS should be private | Clear security boundary |
| One NAT | Exam cost rule | Private pulls still work; bill stays lower |
| Subnet role tags (`kubernetes.io/role/elb`, cluster name) | AWS Load Balancer Controller discovers subnets by tags | Ingress can provision an ALB without manual subnet IDs |

Single NAT is not high availability — say that in the write-up if a grader asks. It is an intentional cost trade-off.
