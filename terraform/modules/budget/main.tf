resource "aws_budgets_budget" "project" {
  name         = var.name
  budget_type  = "COST"
  limit_amount = tostring(var.limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name = "TagKeyValue"
    # NOTE: `$${...}` is Terraform's escape for a literal "${" — it disables
    # interpolation entirely. That previously shipped this filter as the raw,
    # never-matching string "user:Project${var.project_tag}", so the budget
    # was scoped to nothing and the alert could never fire. format() avoids
    # the ambiguity outright.
    values = [format("user:Project$%s", var.project_tag)]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
  }
}
