# budget.tf — Monthly spend ceiling with tiered email alerts
#
# What this does:
#   Creates an AWS Budget that tracks actual spend against your monthly limit.
#   Sends an alert at 50%, 80%, and 100% of the limit so you get early warning
#   before hitting the ceiling.
#
# AWS CLI equivalent (read existing budgets):
#   aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text)
#
# Cost to run: $0 — first two budgets per account are free.

data "aws_caller_identity" "current" {}

resource "aws_budgets_budget" "monthly" {
  name         = "monthly-cost-limit"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alert at 50% — early heads-up while there is still time to act.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Alert at 80% — spending is elevated, investigate now.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Alert at 100% — limit reached.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Forecast alert at 100% — AWS predicts you will exceed the limit this month
  # before you actually do. Gives you a chance to cut spend proactively.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }
}
