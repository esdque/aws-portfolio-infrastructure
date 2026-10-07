---
title: Home
description: Enterprise Infrastructure-as-Code Platform — Terraform module library and CI/CD foundation for 30 AWS portfolio projects.
---

# Enterprise IaC Platform

**Project 19 · Build Order #1 · Foundation for all 30 portfolio projects**

---

!!! success "What This Platform Does"
    This is the infrastructure foundation that every other project in this portfolio runs on.
    Before you can deploy a VPC, a database, or a container cluster — this platform must exist.
    It creates the **S3 bucket**, **DynamoDB lock table**, and **KMS encryption key** that
    Terraform itself needs to operate safely.

## At a Glance

| Property | Value |
|---|---|
| **Terraform version** | >= 1.5 |
| **AWS Provider** | hashicorp/aws ~> 5.0 |
| **Region** | ca-central-1 (Canada) |
| **Environments** | dev · staging · production |
| **Monthly cost** | ~$1.52 (bootstrap infrastructure only) |
| **CI/CD** | GitHub Actions · OIDC (no stored credentials) |
| **Security scanning** | Checkov + OPA/Conftest |
| **State backend** | S3 + DynamoDB + KMS |

## What Was Built

```
terraform/
├── bootstrap/          ← S3 bucket, DynamoDB lock table, KMS key (run FIRST)
├── modules/            ← Reusable module library (8 modules)
│   ├── vpc/            ← Network foundation
│   ├── iam/            ← GitHub OIDC roles
│   ├── ec2/            ← Compute instances
│   ├── rds/            ← PostgreSQL database
│   ├── ecs/            ← Fargate containers
│   ├── eks/            ← Kubernetes
│   ├── cloudfront/     ← CDN + WAF
│   └── monitoring/     ← CloudWatch + SNS
└── environments/
    ├── dev/
    ├── staging/
    └── production/
```

## How to Navigate This Documentation

| Section | What You'll Find |
|---|---|
| [Getting Started](getting-started/index.md) | Step-by-step setup from zero |
| [Architecture](architecture/index.md) | System design + all 5 ADRs |
| [Module Library](modules/index.md) | How to use each module |
| [CI/CD Pipeline](cicd/index.md) | How the GitHub Actions pipeline works |
| [Security](security/threat-model.md) | Threat model + Well-Architected review |
| [Cost](cost/analysis.md) | Per-resource cost breakdown |
| [Operations](operations/runbook.md) | Runbooks for day-to-day operations |
| [Evidence](evidence/index.md) | Screenshots and recordings of the live deployment |

## Business Context

> A Canadian technology company scaling from 5 to 50 engineers needed to eliminate
> "snowflake" infrastructure — environments built by hand, impossible to reproduce,
> with no audit trail and unpredictable costs. This platform solves that with
> IaC-first discipline, automated validation, and keyless CI/CD authentication.

---

*Last updated: see git history · Author: Rahmat Hassan*
