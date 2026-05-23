output "sns_topic_arn" {
  description = "ARN of the SNS topic receiving all cost alerts."
  value       = aws_sns_topic.cost_alerts.arn
}

output "budget_name" {
  description = "Name of the AWS Budget resource."
  value       = aws_budgets_budget.monthly.name
}

output "next_step" {
  description = "Reminder: check your email and confirm the SNS subscription before alerts will deliver."
  value       = "Check ${var.alert_email} for a subscription confirmation email and click the link."
}
