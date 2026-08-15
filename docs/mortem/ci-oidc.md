# GitHub could not log into AWS (OIDC)

**In plain English:** the pipeline tried to use a temporary AWS login from GitHub, and AWS said “no.”

## What you would see

Step **Configure AWS credentials (OIDC)** fails with:

`Not authorized to perform sts:AssumeRoleWithWebIdentity`

Nothing else in Terraform runs after that.

## Why it happened

1. **Wrong place for the role.** The IAM role for GitHub lived inside the main stack (`terraform/envs`). CI needs that role *before* the main stack exists — same chicken-and-egg as the state bucket. It belongs in **bootstrap**.
2. **New GitHub repo ID format.** Repos created after **15 July 2026** send a token subject like:

   `repo:ORG@123/REPO@456:ref:refs/heads/dev`

   If the IAM trust policy only allows `repo:ORG/REPO:...`, AWS rejects it.

## What we changed

- Created the OIDC provider + role `project-bedrock-github-actions` in `terraform/bootstrap/`.
- Allowed both the new ID form and the old name form for `main`, `dev`, and pull requests.
- GitHub secret is only `AWS_ROLE_ARN` — **no** AWS access keys in the repo.
- Role has broad admin rights so Terraform can create the full exam stack (student account).

## Remember

Bootstrap = state bucket **and** CI login. For new GitHub repos, put the numeric owner/repo IDs into the trust policy.
