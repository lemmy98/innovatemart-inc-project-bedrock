data "archive_file" "lambda" {
  type       = "zip"
  source_dir = var.lambda_source_dir
  # Non-hidden path: actions/upload-artifact skips directories starting with '.'
  output_path = "${path.module}/build/${var.lambda_name}.zip"
}

resource "aws_s3_bucket" "assets" {
  bucket = var.bucket_name
  tags   = merge(var.tags, { Name = var.bucket_name })
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Name = var.lambda_name })
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid     = "ReadUploadedObject"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.assets.arn}/*"
    ]
  }

  statement {
    sid = "WriteLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = merge(var.tags, { Name = "${var.lambda_name}-role" })
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.lambda_name}-least-privilege"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_lambda_function" "processor" {
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10
  memory_size      = 128
  architectures    = ["x86_64"]

  depends_on = [aws_cloudwatch_log_group.lambda]

  tags = merge(var.tags, { Name = var.lambda_name })
}

resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "assets" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3]
}
