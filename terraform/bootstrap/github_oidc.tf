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

# Student exam stacks need broad create/destroy. Tighten later if you split accounts.
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
