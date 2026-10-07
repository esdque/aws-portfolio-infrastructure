---
title: System Overview
description: Four-level architecture breakdown of the IaC platform.
---

# Architecture Overview

## Level 1 — Business Flow

```
Developer writes infrastructure code
         │
         ▼
Peer review (Pull Request)
         │
         ▼
Automated validation (CI pipeline)
    fmt → validate → tflint → checkov → OPA → plan
         │
         ▼
Infrastructure deployed to AWS (on merge to main)
         │
         ▼
Evidence captured + documented here
```

---

## Level 2 — System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Developer Workflow                        │
│  Write Terraform → Commit → Push → Open PR → Review → Merge  │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                  CI/CD Pipeline (GitHub Actions)              │
│  On PR:    fmt → validate → tflint → checkov → OPA → plan    │
│  On merge: apply role → terraform apply → notify             │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                        AWS Account                            │
│  ┌──────────────────┐    ┌──────────────────────────────────┐ │
│  │  State Backend   │    │    Deployed Infrastructure       │ │
│  │  S3 bucket       │    │  VPC · IAM · EC2 · RDS · ECS     │ │
│  │  DynamoDB table  │    │  EKS · CloudFront · Monitoring   │ │
│  │  KMS key         │    │  (each in terraform/modules/)    │ │
│  └──────────────────┘    └──────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

---

## Level 3 — Repository Structure

```
terraform/
│
├── bootstrap/          ← Run FIRST. Creates the state infrastructure.
│   ├── main.tf         ← aws_s3_bucket, aws_dynamodb_table, aws_kms_key
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf
│
├── modules/            ← The module library. Reusable building blocks.
│   ├── vpc/
│   ├── iam/
│   ├── ec2/
│   ├── rds/
│   ├── ecs/
│   ├── eks/
│   ├── cloudfront/
│   └── monitoring/
│
└── environments/       ← Root modules. Assemble modules per environment.
    ├── dev/
    ├── staging/
    └── production/
```

!!! info "Two Types of Infrastructure"
    **Bootstrap** (`terraform/bootstrap/`) — what Terraform itself needs: S3, DynamoDB, KMS.
    Run once, manually, before anything else. Cannot be managed by the same state it creates.

    **Modules** (`terraform/modules/`) — what your applications run on: VPCs, databases,
    containers. These are assembled in `environments/` and deployed by the CI/CD pipeline.

---

## Level 4 — Security Architecture (OIDC Flow)

```
GitHub Actions Workflow
     │
     │  Step 1: Request short-lived OIDC token from GitHub
     │  Step 2: Send token to AWS STS AssumeRoleWithWebIdentity
     ▼
aws-actions/configure-aws-credentials
     │
     │  AWS validates token against registered OIDC provider:
     │  token.actions.githubusercontent.com
     ▼
Two IAM Roles (never long-lived keys)
     │
     ├── Plan Role (PR checks)
     │   Condition: StringLike — any branch/event
     │   Permissions: Read-only (S3 Get, DynamoDB Get, KMS Decrypt)
     │
     └── Apply Role (merge to main only)
         Condition: StringEquals — refs/heads/main ONLY
         Permissions: Read + Write (create/modify/destroy resources)
         Deny: RDS deletion, KMS deletion, S3 state bucket deletion
```

No AWS credentials are stored in GitHub Secrets. Tokens expire after 1 hour.

---

## Architecture Decision Records

Five key decisions shaped this architecture:

| ADR | Decision | Why |
|---|---|---|
| [ADR-001](decisions/001-terraform-vs-cloudformation.md) | Terraform over CloudFormation | Industry standard, multi-cloud, better plan output |
| [ADR-002](decisions/002-s3-dynamodb-vs-terraform-cloud.md) | S3+DynamoDB over Terraform Cloud | Data sovereignty, cost, operational skill |
| [ADR-003](decisions/003-directories-vs-workspaces.md) | Directories over Workspaces | Safety — can't accidentally run in production |
| [ADR-004](decisions/004-checkov-plus-opa.md) | Checkov + OPA (both) | Different concerns — neither alone is sufficient |
| [ADR-005](decisions/005-oidc-vs-access-keys.md) | OIDC over access keys | No credentials to leak, 1-hour TTL, full audit trail |
