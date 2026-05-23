# AWS CLI Reference

Every resource this repo creates can also be inspected (and in some cases created) with the AWS CLI. Use this as a reference to understand what Terraform is managing under the hood.

## SNS — Notifications

| Action | AWS CLI |
|---|---|
| List all SNS topics | `aws sns list-topics` |
| List subscriptions for a topic | `aws sns list-subscriptions-by-topic --topic-arn <arn>` |
| Publish a test message | `aws sns publish --topic-arn <arn> --message "test"` |
| Delete a topic | `aws sns delete-topic --topic-arn <arn>` |

## AWS Budgets

| Action | AWS CLI |
|---|---|
| List all budgets | `aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text)` |
| Check current spend vs limit | `aws budgets describe-budget --account-id <id> --budget-name <name>` |
| List budget notifications | `aws budgets describe-notifications-for-budget --account-id <id> --budget-name <name>` |

## Cost Explorer

| Action | AWS CLI |
|---|---|
| MTD total spend | `aws ce get-cost-and-usage --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics UnblendedCost` |
| MTD by service | `aws ce get-cost-and-usage --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics UnblendedCost --group-by Type=DIMENSION,Key=SERVICE` |
| Month-end forecast | `aws ce get-cost-forecast --time-period Start=$(date +%Y-%m-%d),End=<last-day-of-month> --granularity MONTHLY --metric UNBLENDED_COST` |
| Last 6 months by month | `aws ce get-cost-and-usage --time-period Start=$(date -d '6 months ago' +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics UnblendedCost` |

## Cost Anomaly Detection

| Action | AWS CLI |
|---|---|
| List anomaly monitors | `aws ce get-anomaly-monitors` |
| List anomaly subscriptions | `aws ce get-anomaly-subscriptions` |
| View recent anomalies | `aws ce get-anomalies --monitor-arn <arn> --date-interval StartDate=$(date -d '30 days ago' +%Y-%m-%d),EndDate=$(date +%Y-%m-%d)` |

## Account & Identity

| Action | AWS CLI |
|---|---|
| Show current account ID | `aws sts get-caller-identity` |
| Show IAM user or role | `aws sts get-caller-identity --query Arn --output text` |
| List named CLI profiles | `aws configure list-profiles` |

---

## Terraform ↔ CLI equivalents

| Terraform resource | What it manages | CLI to inspect |
|---|---|---|
| `aws_sns_topic` | Message bus for alerts | `aws sns list-topics` |
| `aws_sns_topic_subscription` | Your email subscription | `aws sns list-subscriptions` |
| `aws_sns_topic_policy` | Who can publish to the topic | `aws sns get-topic-attributes --topic-arn <arn>` |
| `aws_budgets_budget` | Monthly spend ceiling | `aws budgets describe-budgets --account-id <id>` |
| `aws_ce_anomaly_monitor` | What pattern to watch | `aws ce get-anomaly-monitors` |
| `aws_ce_anomaly_subscription` | Alert threshold and destination | `aws ce get-anomaly-subscriptions` |
