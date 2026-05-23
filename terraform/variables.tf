variable "aws_region" {
  description = "AWS region to deploy resources in. Cost Explorer data is global, but SNS topics are regional."
  type        = string
  default     = "us-east-1"
}

variable "monthly_budget_usd" {
  description = "Your monthly spend limit in USD. Alerts fire at 50%, 80%, and 100% of this amount."
  type        = number
  default     = 20
}

variable "alert_email" {
  description = "Email address to receive budget and anomaly alerts. You will get a confirmation email — click the link before alerts will deliver."
  type        = string
}

variable "anomaly_threshold_usd" {
  description = "Alert when a single anomaly exceeds this dollar amount above expected spend."
  type        = number
  default     = 10
}
