resource "aws_iam_user" "developer" {
  name = var.user_name
  path = "/"
  tags = merge(var.tags, { Name = var.user_name })
}

resource "aws_iam_user_login_profile" "developer" {
  user                    = aws_iam_user.developer.name
  password_reset_required = true
  password_length         = 20
}

resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Exam user must not keep AdministratorAccess (or any extra managed policy).
# Without this, IAM Policy Simulator returns allowed for s3:DeleteObject.
resource "aws_iam_user_policy_attachments_exclusive" "developer" {
  user_name = aws_iam_user.developer.name
  policy_arns = [
    aws_iam_user_policy_attachment.readonly.policy_arn,
  ]
}

resource "aws_iam_user_policy" "assets_put" {
  name = "${var.user_name}-assets-put"
  user = aws_iam_user.developer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PutProductImages"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${var.assets_bucket_arn}/*"
      },
      {
        # Resource "*" so the simulator still returns explicitDeny when the
        # resource ARN is omitted. Explicit Deny wins over AdministratorAccess
        # if that policy is still attached until the exclusive attachment runs.
        Sid    = "DenyDeleteProductImages"
        Effect = "Deny"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:DeleteObjectTagging",
          "s3:DeleteObjectVersionTagging",
        ]
        Resource = [
          "*",
          "${var.assets_bucket_arn}/*",
        ]
      }
    ]
  })
}
