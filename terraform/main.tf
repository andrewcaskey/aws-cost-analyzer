# main.tf — Provider, SNS topic, and email subscription
#
# What this does:
#   Configures the AWS provider and creates the notification pipeline:
#   SNS topic (a message bus) → email subscription (your inbox).
#   All alerts from budget.tf and anomaly.tf route through this topic.
#
# AWS CLI equivalent:
#   aws sns create-topic --name cost-alerts
#   aws sns subscribe --topic-arn <arn> --protocol email --notification-endpoint you@example.com

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "aws-cost-analyzer"
      ManagedBy = "terraform"
    }
  }
}

# Central notification topic — all cost alerts publish here.
resource "aws_sns_topic" "cost_alerts" {
  name = "cost-alerts"
}

# Email subscription — AWS sends a confirmation link on first apply.
# Alerts will not deliver until you click that link.
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
