terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  env         = "dev"
  common_tags = {
    Environment = local.env
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = var.owner_email
  }
}

# ── VPC ──────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  vpc_name          = "${var.project_name}-${local.env}"
  vpc_cidr          = var.vpc_cidr
  az_count          = 2
  nat_gateway_count = 0          # No NAT in dev — saves ~$32/month
  enable_flow_logs  = false       # Optional in dev
  tags              = local.common_tags
}

# ── IAM / OIDC ───────────────────────────────────────────────────────────────
module "iam" {
  source = "../../modules/iam"

  project_name         = "${var.project_name}-${local.env}"
  github_org           = var.github_org
  github_repo          = var.github_repo
  create_oidc_provider = var.create_oidc_provider
  state_bucket_name    = var.state_bucket_name
  lock_table_name      = var.lock_table_name
  kms_key_arn          = var.kms_key_arn
  tags                 = local.common_tags
}

# ── Monitoring ────────────────────────────────────────────────────────────────
module "monitoring" {
  source = "../../modules/monitoring"

  project_name               = "${var.project_name}-${local.env}"
  aws_region                 = var.aws_region
  kms_key_id                 = var.kms_key_id
  alert_emails               = var.alert_emails
  billing_alarm_threshold_usd = 20
  monthly_budget_usd         = 30
  tags                       = local.common_tags
}
