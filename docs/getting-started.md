# Getting Started

Deploy budget alerts and anomaly detection to your AWS account in about 10 minutes.

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Terraform | >= 1.6 | [terraform.io/downloads](https://developer.hashicorp.com/terraform/downloads) |
| AWS CLI | v2 | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| Python | >= 3.9 | For `scripts/cost-breakdown.py` only |
| boto3 | latest | `pip install boto3` — for the Python script only |

## Step 1 — Configure an AWS CLI profile

If you already have a named profile skip this step.

```bash
aws configure --profile my-profile
# Enter your Access Key ID, Secret Access Key, region (us-east-1), output format (json)
```

Verify it works:
```bash
aws sts get-caller-identity --profile my-profile
```

## Step 2 — Set environment variables

```bash
export AWS_PROFILE=my-profile
export AWS_REGION=us-east-1
```

Or copy `.env.example` to `.env`, fill in your values, and run `source .env`.

## Step 3 — Initialize Terraform

```bash
make init
```

This downloads the AWS provider plugin (~50 MB). Nothing is created in AWS yet.

## Step 4 — Preview the plan

```bash
make plan
```

Terraform shows you exactly what it will create before touching anything. You should see 5 resources: 1 SNS topic, 1 email subscription, 1 budget, 1 anomaly monitor, 1 anomaly subscription.

You will be prompted for two variables:
- `alert_email` — the email address to receive alerts
- `monthly_budget_usd` — your monthly spend ceiling (default: 20)

To avoid the prompts, create `terraform/terraform.tfvars`:
```hcl
alert_email        = "you@example.com"
monthly_budget_usd = 20
```

## Step 5 — Deploy

```bash
make apply
```

Type `yes` when prompted. Terraform creates all 5 resources in about 15 seconds.

## Step 6 — Confirm your email subscription

AWS sends a confirmation email to the address you provided. **Click the confirmation link** — alerts will not deliver until you do.

## Step 7 — Verify it works

Check your budget is live:
```bash
make cost-cli
```

Or run the Python breakdown:
```bash
make cost
```

## Tearing it down

```bash
make destroy
```

All resources created by this repo will be removed. Your AWS account and billing data are unaffected.

---

## How Terraform state works

Terraform keeps a `terraform.tfstate` file that tracks what it has created. By default this lives locally in `terraform/`. This is fine for learning and personal use.

For a team or production setup, store state in S3 instead. Uncomment the `backend "s3"` block in `terraform/terraform.tf` and create the bucket first:

```bash
aws s3 mb s3://your-state-bucket --region us-east-1
aws s3api put-bucket-versioning \
  --bucket your-state-bucket \
  --versioning-configuration Status=Enabled
```
