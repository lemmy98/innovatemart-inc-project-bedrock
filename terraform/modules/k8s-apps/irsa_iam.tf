module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.55"

  role_name                              = "${var.cluster_name}-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "carts" {
  statement {
    sid = "CartsDynamo"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:DescribeTable",
      "dynamodb:ConditionCheckItem",
    ]
    resources = [
      var.dynamodb_table_arn,
      "${var.dynamodb_table_arn}/index/*",
    ]
  }
}

resource "aws_iam_policy" "carts" {
  name   = "${var.cluster_name}-carts-dynamodb"
  policy = data.aws_iam_policy_document.carts.json
  tags   = var.tags
}

module "carts_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.55"

  role_name = "${var.cluster_name}-carts"

  role_policy_arns = {
    dynamodb = aws_iam_policy.carts.arn
  }

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.app_namespace}:carts"]
    }
  }

  tags = var.tags
}
