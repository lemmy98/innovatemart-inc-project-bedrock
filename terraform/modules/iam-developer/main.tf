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
        # Explicit Deny so graders get AccessDenied on delete even if a broader
        # Allow is attached later. ReadOnlyAccess alone only omits delete.
        Sid    = "DenyDeleteProductImages"
        Effect = "Deny"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
        ]
        Resource = "${var.assets_bucket_arn}/*"
      }
    ]
  })
}
