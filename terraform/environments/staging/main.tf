terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.common_tags }
}

locals {
  env         = "staging"
  common_tags = {
    Environment = local.env
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = var.owner_email
  }
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name          = "${var.project_name}-${local.env}"
  vpc_cidr          = var.vpc_cidr
  az_count          = 2
  nat_gateway_count = 1           # 1 NAT — cost/HA balance
  enable_flow_logs  = true
  tags              = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name         = "${var.project_name}-${local.env}"
  github_org           = var.github_org
  github_repo          = var.github_repo
  create_oidc_provider = false    # Already created in dev
  state_bucket_name    = var.state_bucket_name
  lock_table_name      = var.lock_table_name
  kms_key_arn          = var.kms_key_arn
  tags                 = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name                = "${var.project_name}-${local.env}"
  aws_region                  = var.aws_region
  kms_key_id                  = var.kms_key_id
  alert_emails                = var.alert_emails
  billing_alarm_threshold_usd = 100
  monthly_budget_usd          = 150
  tags                        = local.common_tags
}
