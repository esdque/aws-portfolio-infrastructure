# AWS Portfolio — Project 19: Infrastructure as Code Platform

> Reusable Terraform module library + automated CI/CD pipeline for all 30 AWS portfolio projects.

[![CI](https://github.com/YOUR-USERNAME/aws-portfolio-infrastructure/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/YOUR-USERNAME/aws-portfolio-infrastructure/actions/workflows/terraform-ci.yml)
[![Security](https://img.shields.io/badge/security-Checkov%20%2B%20OPA-blue)](docs/security/)
[![Docs](https://img.shields.io/badge/docs-MkDocs%20Material-blue)](https://YOUR-USERNAME.github.io/aws-portfolio-infrastructure)

## What This Builds

| Component | Purpose |
|-----------|---------|
| `terraform/bootstrap/` | S3 state bucket + DynamoDB lock table + KMS key |
| `terraform/modules/vpc/` | Three-tier VPC (public / private-app / private-data) |
| `terraform/modules/iam/` | GitHub Actions OIDC — keyless CI/CD authentication |
| `terraform/modules/ec2/` | Auto Scaling Group with IMDSv2, SSM access |
| `terraform/modules/rds/` | Encrypted PostgreSQL with Multi-AZ option |
| `terraform/modules/ecs/` | Fargate cluster with Container Insights |
| `terraform/modules/monitoring/` | SNS alerts + CloudWatch dashboard + AWS Budgets |
| `.github/workflows/` | Terraform CI, plan-on-PR, apply-on-merge |
| `policies/opa/` | Required tags + security controls enforcement |
| `tests/terratest/` | Go integration tests against real AWS |

## Quick Start

```bash
# 1. Bootstrap (first time only)
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars  # edit with your values
terraform init
terraform apply

# 2. Deploy dev environment
cd terraform/environments/dev
terraform init
terraform apply
```

See [Getting Started →](https://YOUR-USERNAME.github.io/aws-portfolio-infrastructure/getting-started/)

## Architecture

```
Internet
    │
    ▼
[Internet Gateway]
    │
    ▼
[Public Subnets]  ──── Load Balancers, NAT Gateways
    │
    ▼ (via NAT)
[Private App Subnets] ── EC2 / ECS / EKS
    │
    ▼ (VPC-only)
[Private Data Subnets] ── RDS / ElastiCache
```

## Documentation

Full documentation at: **https://YOUR-USERNAME.github.io/aws-portfolio-infrastructure**

## Cost

| Environment | Monthly Cost |
|-------------|-------------|
| Dev | ~$1.52 (bootstrap only, no NAT) |
| Staging | ~$35 (1 NAT gateway + bootstrap) |
| Production | ~$105 (3 NAT gateways + full HA) |

## License

MIT
