# eks

## What it is

Cluster `project-bedrock-cluster` on Kubernetes **1.34**, managed node group `retail` (2 × `t3.small`) in private subnets, IRSA enabled, API authentication mode (no `aws-auth` ConfigMap).

## Why

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Version 1.34 | Exam asks for oldest *standard-support* EKS version | Stays supported without jumping to brand-new releases |
| `t3.small` × 2 (max 3) | Micro nodes OOM the Java services | Pods schedule; CA can add one extra node for the 5.3 demo |
| Access Entries + `AmazonEKSViewPolicy` on `retail-app` | Exam wants a view-only developer on the namespace | Modern EKS auth; no hand-edited aws-auth |
| Control-plane logs + Observability add-on | Exam wants visible logs | API audit trail + container logs in CloudWatch |
| Helm CLI via cloud-init | Exam wording about Helm on nodes | Binary present on the box; charts still come from Terraform in stage 2 |
| Short node group name (`retail`) | Long names break IAM `name_prefix` (38 char limit) | Apply succeeds |

If pods stay Pending on memory, bump `node_instance_types` in tfvars — do not hard-code a bigger size in the module.
