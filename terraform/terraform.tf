terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state by default — good enough for learning.
  # To switch to S3 remote state, uncomment and fill in:
  #
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "aws-cost-analyzer/terraform.tfstate"
  #   region = "us-east-1"
  # }
  #
  # AWS CLI equivalent to create the bucket:
  #   aws s3 mb s3://your-terraform-state-bucket --region us-east-1
  #   aws s3api put-bucket-versioning --bucket your-terraform-state-bucket \
  #     --versioning-configuration Status=Enabled
}
