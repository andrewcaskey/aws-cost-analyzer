#!/usr/bin/env bash
# quick-costs.sh — AWS CLI one-liners for common cost queries.
#
# Usage: bash scripts/quick-costs.sh
# Requires: AWS CLI v2, jq
# Set AWS_PROFILE before running: export AWS_PROFILE=your-profile

set -euo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
START=$(date +%Y-%m-01)
END=$(date +%Y-%m-%d)

echo ""
echo "Account: $ACCOUNT_ID"
echo "Period:  $START → $END"
echo ""

# ── MTD total ──────────────────────────────────────────────────────────────────
echo "Month-to-date total:"
aws ce get-cost-and-usage \
  --time-period "Start=$START,End=$END" \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --query 'ResultsByTime[0].Total.UnblendedCost.{Amount:Amount,Unit:Unit}' \
  --output table
echo ""

# ── Top 5 services ─────────────────────────────────────────────────────────────
echo "Top 5 services by cost:"
aws ce get-cost-and-usage \
  --time-period "Start=$START,End=$END" \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query 'sort_by(ResultsByTime[0].Groups, &Metrics.UnblendedCost.Amount)[-5:] | reverse(@) | [].{Service:Keys[0], Cost:Metrics.UnblendedCost.Amount}' \
  --output table
echo ""

# ── Month-end forecast ─────────────────────────────────────────────────────────
echo "Forecasted cost through end of month:"
MONTH_END=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d 2>/dev/null \
  || python3 -c "import calendar, datetime; t=datetime.date.today(); print(datetime.date(t.year, t.month, calendar.monthrange(t.year, t.month)[1]))")

aws ce get-cost-forecast \
  --time-period "Start=$END,End=$MONTH_END" \
  --granularity MONTHLY \
  --metric UNBLENDED_COST \
  --query '{ForecastedAmount:Total.Amount,Unit:Total.Unit}' \
  --output table 2>/dev/null || echo "  (Not enough data for a forecast yet — check back after a few days of spend)"
echo ""

# ── Active budget status ────────────────────────────────────────────────────────
echo "Budget status:"
aws budgets describe-budgets \
  --account-id "$ACCOUNT_ID" \
  --query 'Budgets[].{Name:BudgetName, Limit:BudgetLimit.Amount, Actual:CalculatedSpend.ActualSpend.Amount, Forecasted:CalculatedSpend.ForecastedSpend.Amount}' \
  --output table 2>/dev/null || echo "  No budgets found — run 'make apply' to create one."
echo ""
