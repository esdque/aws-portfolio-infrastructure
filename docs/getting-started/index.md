---
title: Quick Start
description: Deploy the IaC platform from zero in five steps.
---

# Quick Start

Five steps from a blank AWS account to a running infrastructure platform.

---

## Step 1 — Install Prerequisites

```bash
# Terraform >= 1.5
brew install terraform           # macOS
# OR: https://developer.hashicorp.com/terraform/install

# AWS CLI v2
brew install awscli              # macOS
# OR: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

# Pre-commit (runs validation hooks before every git commit)
pip install pre-commit

# Go 1.21+ (for Terratest — infrastructure tests)
brew install go

# Verify all installed
terraform version
aws --version
pre-commit --version
go version
```

---

## Step 2 — Configure AWS Credentials

```bash
# Recommended: AWS SSO
aws configure sso
aws sso login --profile your-profile-name

# Verify you're connected to the right account
aws sts get-caller-identity
```

!!! warning "Region"
    All resources in this project deploy to **ca-central-1** (Canada). If you use a
    different region, update `terraform.tfvars` in each environment folder.

---

## Step 3 — Bootstrap (Creates State Infrastructure)

!!! info "Why Bootstrap First?"
    Terraform stores its state in S3 — but S3 doesn't exist yet. The bootstrap solves
    this by running with **local state first**, creating S3, then migrating state to S3.

```bash
cd terraform/bootstrap

# Edit terraform.tfvars with your values
# (company_name, aws_account_id, aws_region)

# First run — local state (before the bucket exists)
terraform init
terraform plan
terraform apply

# After apply completes, migrate state to the new S3 bucket
terraform init -migrate-state
```

See [Bootstrap Guide](bootstrap.md) for full details and verification steps.

---

## Step 4 — Configure GitHub Secrets

In your GitHub repository → **Settings → Secrets and variables → Actions**:

| Variable | Value | Type |
|---|---|---|
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID | Variable (not secret) |
| `TF_STATE_BUCKET` | Name of the S3 bucket created in Step 3 | Variable |
| `TF_LOCK_TABLE` | Name of the DynamoDB table created in Step 3 | Variable |
| `TF_KMS_KEY_ID` | KMS key ID created in Step 3 | Variable |
| `PLAN_ROLE_ARN` | ARN of the plan IAM role | Variable |
| `APPLY_ROLE_ARN` | ARN of the apply IAM role | Variable |

No passwords or access keys. Authentication uses OIDC — see [ADR-005](../architecture/decisions/005-oidc-vs-access-keys.md).

---

## Step 5 — Deploy Dev Environment

```bash
cd terraform/environments/dev

terraform init
terraform plan
terraform apply
```

Commit, open a pull request, and the CI pipeline runs automatically.

---

## What Happens Next

After Step 5, every pull request to your repository will:

1. Run `terraform fmt` (format check)
2. Run `terraform validate` (syntax check)
3. Run `tflint` (AWS-specific rule validation)
4. Run `checkov` (security scanning — 1000+ rules)
5. Run OPA/Conftest (custom business policy checks)
6. Post the `terraform plan` output as a PR comment
7. Block merge if any check fails

On merge to `main`, `terraform apply` runs automatically with the apply role.
