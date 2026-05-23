# aws-cost-analyzer

A minimal, educational Terraform project that adds **budget alerts and cost anomaly detection** to any AWS account. Deploy in under 10 minutes, learn Terraform and AWS CLI concepts along the way.

## What it does

| Feature | How |
|---|---|
| Email alert at 50%, 80%, 100% of monthly limit | AWS Budgets → SNS |
| Email alert when spend pattern is unusual | Cost Anomaly Detection → SNS |
| CLI breakdown of MTD spend by service | Python script or shell one-liners |

**Cost to run:** $0. AWS Budgets (first 2 free), Cost Anomaly Detection, and SNS (first 1M publishes free per month) are all within the free tier for typical personal account usage.

## Architecture

```
AWS Cost Explorer
        │
        ├── AWS Budgets ──────────────────┐
        │   (50% / 80% / 100% thresholds) │
        │                                 ▼
        └── Cost Anomaly Detection ──► SNS Topic ──► Your Email
                (ML-based spike detection)
```

## Quick start

```bash
# 1. Set your AWS profile
export AWS_PROFILE=your-profile-name

# 2. Initialize and preview
make init
make plan

# 3. Deploy (you'll be prompted for email + budget amount)
make apply
```

Then check your inbox and **click the SNS subscription confirmation link**.

## Inputs

| Variable | Description | Default |
|---|---|---|
| `alert_email` | Email to receive all alerts | required |
| `monthly_budget_usd` | Monthly spend ceiling in USD | `20` |
| `anomaly_threshold_usd` | Minimum anomaly size to alert on (USD) | `10` |
| `aws_region` | AWS region for SNS topic | `us-east-1` |

Set these in `terraform/terraform.tfvars` to avoid being prompted:

```hcl
alert_email        = "you@example.com"
monthly_budget_usd = 20
```

## Makefile targets

```
make help        Show all targets
make init        Initialize Terraform
make plan        Preview changes
make apply       Deploy to AWS
make destroy     Remove all resources
make cost        Python MTD breakdown by service
make cost-cli    Shell MTD breakdown + forecast
make fmt         Auto-format Terraform files
make validate    Validate Terraform config
```

## What you'll learn

- **Terraform basics**: providers, resources, variables, outputs, state
- **AWS SNS**: topics, subscriptions, topic policies
- **AWS Budgets**: budget types, notification thresholds, forecast alerts
- **Cost Anomaly Detection**: monitors, subscriptions, threshold expressions
- **AWS Cost Explorer**: querying spend via CLI and boto3
- **IAM concepts**: why services need explicit SNS publish permissions

Each `.tf` file includes comments explaining the "why" alongside the code, plus the equivalent AWS CLI command for the resource it manages.

## Docs

- [Getting started](docs/getting-started.md) — step-by-step setup walkthrough
- [AWS CLI reference](docs/aws-cli-reference.md) — CLI equivalents for every resource

## Repository layout

```
terraform/       Flat Terraform files (no modules)
  main.tf        Provider + SNS topic + email subscription
  budget.tf      Monthly budget with tiered alerts
  anomaly.tf     Cost anomaly monitor and subscription
  variables.tf   Input variables
  outputs.tf     Resource ARNs and next steps
  terraform.tf   Provider version requirements
scripts/
  cost-breakdown.py   MTD per-service breakdown (boto3)
  quick-costs.sh      AWS CLI one-liners
docs/
  getting-started.md
  aws-cli-reference.md
```
