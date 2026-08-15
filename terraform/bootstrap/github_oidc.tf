# GitHub Actions OIDC — create here (with the state bucket), not in envs.
# CI needs this role *before* it can plan/apply terraform/envs.
# Exam: OIDC preferred; long-lived access keys are the fallback we avoid.
#
# Repos created on github.com on/after 2026-07-15 emit an *immutable* sub claim:
#   repo:ORG@OWNER_ID/REPO@REPO_ID:ref:refs/heads/BRANCH
# Matching only the legacy name-only form fails AssumeRoleWithWebIdentity.

locals {
  github_owner = split("/", var.github_repository)[0]
  github_repo  = split("/", var.github_repository)[1]

  # Immutable form (required for this repo — created after 2026-07-15)
  github_sub_prefix = "${local.github_owner}@${var.github_owner_id}/${local.github_repo}@${var.github_repository_id}"

  github_oidc_subjects = [
    "repo:${local.github_sub_prefix}:ref:refs/heads/main",
    "repo:${local.github_sub_prefix}:ref:refs/heads/dev",
    "repo:${local.github_sub_prefix}:pull_request",
    # Legacy name-only form (harmless extra; needed if a repo has not opted into immutable subs)
    "repo:${var.github_repository}:ref:refs/heads/main",
    "repo:${var.github_repository}:ref:refs/heads/dev",
    "repo:${var.github_repository}:pull_request",
  ]
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # AWS ignores thumbprints for GitHub's IdP; API still requires at least one value.
  thumbprint_list = [
    data.tls_certificate.github.certificates[length(data.tls_certificate.github.certificates) - 1].sha1_fingerprint,
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "project-bedrock-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json

  tags = {
    Name = "project-bedrock-github-actions"
  }
}

# Scoped down from AdministratorAccess to the AWS services terraform/envs and
# terraform/bootstrap actually touch. Kept at the AWS-service level (Resource
# "*" within each service's action namespace) rather than hand-enumerating
# every action + resource ARN: most of what's below (VPC/EKS/RDS create calls)
# doesn't support meaningful resource-level scoping anyway, and a wrong,
# too-narrow guess here fails a real `terraform apply` with no way to test it
# from outside a live AWS account. This is still a large cut from full account
# admin (no Organizations, Billing, IAM outside this role's own needs, no
# services this project doesn't use, etc.).
#
# If a future `terraform apply` fails on a missing permission, the previous
# AdministratorAccess attachment is left below, commented out, as a fast
# rollback — uncomment it, comment out the scoped attachment, apply, then
# add the missing action here and revert.
data "aws_iam_policy_document" "github_actions_scoped" {
  statement {
    sid = "CoreInfra"
    actions = [
      "ec2:*",
      "eks:*",
      "autoscaling:*",
      "rds:*",
      "dynamodb:*",
      "s3:*",
      "lambda:*",
      "logs:*",
      "secretsmanager:*",
      "budgets:*",
      # KMS: the EKS module manages a key + alias for cluster secrets
      # encryption (module.kms.aws_kms_alias.this["cluster"]) — missing
      # this broke a real `terraform plan` with
      # "AccessDeniedException: kms:ListAliases".
      "kms:*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    # Full iam:* rather than a hand-enumerated action list: this repo's
    # modules create roles, policies, an OIDC provider, instance profiles,
    # and an IAM user (with access key + login profile) across bootstrap and
    # envs, and a hand-picked list that's missing even one action (e.g. an
    # internal existence-check call a module makes) fails a real apply with
    # no way to test it from outside a live AWS account. Still a large cut
    # from AdministratorAccess: no other service outside "CoreInfra" above,
    # no Organizations/Billing/account settings.
    sid       = "IamForRolesPoliciesAndCiUser"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_scoped" {
  name        = "project-bedrock-github-actions-scoped"
  description = "Least-privilege-by-service policy for the Terraform CI role (Project Bedrock)."
  policy      = data.aws_iam_policy_document.github_actions_scoped.json

  tags = {
    Name = "project-bedrock-github-actions-scoped"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_scoped.arn
}

# Rollback fallback only — do not attach alongside the scoped policy above.
# resource "aws_iam_role_policy_attachment" "github_actions_admin_fallback" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
