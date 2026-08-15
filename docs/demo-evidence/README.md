# Demo evidence

Command output I capture for exam screenshots. I use the live console or these files.

| File | Proof |
| --- | --- |
| `01-tls.txt` | **5.2** HTTPS + ACM on `lemikan-third-semester-exam-project.fyi` |
| `02-iam-deny.txt` | IAM `explicitDeny` on `s3:DeleteObject` for `bedrock-dev-view` |
| `03-lambda.txt` | S3 → Lambda `Image received: …` |
| `04-selfheal.txt` | **5.5** UI pod replaced + RDS `BackupRetention=1` |
| `05-np-deny.txt` | **5.4** catalog-labelled probe blocked from orders |
| `06-ca-scale.txt` | **5.3** Cluster Autoscaler brought a 3rd Ready node |

Shop: `https://lemikan-third-semester-exam-project.fyi/` (ALB + ACM). I keep Cloudflare **DNS-only** so the cert issuer stays Amazon.
