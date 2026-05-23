# anomaly.tf — Cost anomaly detection
#
# What this does:
#   AWS Cost Anomaly Detection uses ML to learn your normal spend pattern
#   and alerts you when something looks unusual — e.g., you left an EC2
#   instance running, or a script made unexpected API calls.
#
#   Two resources are required:
#     1. Monitor  — defines *what* to watch (your whole account here)
#     2. Subscription — defines *when* to alert and *where* to send it
#
# AWS CLI equivalent (list existing monitors):
#   aws ce get-anomaly-monitors
#   aws ce get-anomaly-subscriptions
#
# Cost to run: $0 — Cost Anomaly Detection is free.

resource "aws_ce_anomaly_monitor" "account" {
  name              = "account-wide-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "alert" {
  name      = "anomaly-email-alert"
  frequency = "DAILY" # options: DAILY, WEEKLY, or IMMEDIATE

  monitor_arn_list = [aws_ce_anomaly_monitor.account.arn]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.cost_alerts.arn
  }

  # Only alert when the anomaly exceeds this absolute dollar threshold.
  # A threshold of $0 would fire on every small fluctuation.
  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.anomaly_threshold_usd)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

# Grant Cost Anomaly Detection permission to publish to the SNS topic.
resource "aws_sns_topic_policy" "allow_anomaly" {
  arn = aws_sns_topic.cost_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCostAnomalyDetection"
        Effect = "Allow"
        Principal = {
          Service = "costalerts.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cost_alerts.arn
      }
    ]
  })
}
