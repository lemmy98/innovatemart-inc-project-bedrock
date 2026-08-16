# iam-developer

## What it is

IAM user `bedrock-dev-view` with:

- AWS managed `ReadOnlyAccess`
- Inline `s3:PutObject` on the assets bucket (graders upload a test image)
- Explicit inline **Deny** on `s3:DeleteObject` (and version/tag deletes) so the IAM simulator returns `explicitDeny`, not `allowed`
- Managed policies limited to `ReadOnlyAccess` (strips leftover `AdministratorAccess`)
- EKS Access Entry mapping (in the **eks** module) to `AmazonEKSViewPolicy` on namespace `retail-app`

## Why

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Separate IAM user | Exam asks for a named developer principal | Graders can log in as that user |
| Secrets stay on the module | Exam forbids secrets in the five root outputs | Use `terraform state show` / console; put values in the Google Doc |
| Access Entry instead of aws-auth | EKS API auth is current best practice | No ConfigMap races |

## How to read credentials (after stage 1 apply)

```bash
cd terraform/envs
terraform state show 'module.iam_developer.aws_iam_access_key.developer'
# or terraform console / state pull — never commit the values
```
