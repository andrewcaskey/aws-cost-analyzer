#!/usr/bin/env python3
"""
cost-breakdown.py — Month-to-date AWS spend broken down by service.

Usage:
    python scripts/cost-breakdown.py

Prerequisites:
    pip install boto3
    AWS_PROFILE environment variable set (or uses the default profile)

Equivalent AWS CLI command (total MTD only):
    aws ce get-cost-and-usage \
      --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
      --granularity MONTHLY \
      --metrics BlendedCost \
      --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
      --output text
"""

import os
import boto3
from datetime import date, timedelta


def get_date_range():
    today = date.today()
    start = today.replace(day=1).isoformat()
    # Cost Explorer end date is exclusive, so use tomorrow if today is the 1st
    end = (today + timedelta(days=1)).isoformat() if today.day == 1 else today.isoformat()
    return start, end


def get_cost_by_service(ce_client, start, end):
    response = ce_client.get_cost_and_usage(
        TimePeriod={"Start": start, "End": end},
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
    )

    results = []
    for group in response["ResultsByTime"][0]["Groups"]:
        service = group["Keys"][0]
        amount = float(group["Metrics"]["UnblendedCost"]["Amount"])
        if amount > 0.001:  # skip noise
            results.append((service, amount))

    return sorted(results, key=lambda x: x[1], reverse=True)


def main():
    profile = os.environ.get("AWS_PROFILE", "default")
    session = boto3.Session(profile_name=profile)
    ce = session.client("ce", region_name="us-east-1")  # CE is always us-east-1

    start, end = get_date_range()
    print(f"\nMTD Cost Breakdown ({start} → {end})  [profile: {profile}]")
    print("-" * 60)

    services = get_cost_by_service(ce, start, end)

    if not services:
        print("No charges found yet this month.")
        return

    total = sum(amount for _, amount in services)
    for service, amount in services:
        bar = "█" * int((amount / total) * 30)
        print(f"  {service:<40} ${amount:>8.4f}  {bar}")

    print("-" * 60)
    print(f"  {'TOTAL':<40} ${total:>8.4f}")
    print()


if __name__ == "__main__":
    main()
