---
title: Prerequisites
description: Everything you need installed and configured before starting.
---

# Prerequisites

## Tools Required

| Tool | Minimum Version | Install |
|---|---|---|
| Terraform | 1.5.0 | [hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install) |
| AWS CLI | 2.x | [docs.aws.amazon.com/cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| Git | 2.x | [git-scm.com](https://git-scm.com) |
| Go | 1.21+ | [go.dev/dl](https://go.dev/dl/) — needed for Terratest |
| pre-commit | 3.x | `pip install pre-commit` |
| Python | 3.9+ | [python.org](https://python.org) — needed for pre-commit and Checkov |
| Checkov | 3.x | `pip install checkov` |
| TFLint | 0.50+ | [github.com/terraform-linters/tflint](https://github.com/terraform-linters/tflint) |
| OPA | 0.60+ | [openpolicyagent.org](https://www.openpolicyagent.org/docs/latest/#running-opa) |
| conftest | 0.46+ | [conftest.dev](https://www.conftest.dev) |

## AWS Account Requirements

- An AWS account with billing enabled
- IAM permissions sufficient to create: S3, DynamoDB, KMS, IAM, VPC resources
- AWS SSO or a named profile configured locally

## GitHub Requirements

- A GitHub account (free tier works)
- A new repository named `aws-portfolio-infrastructure`
- GitHub Actions enabled (enabled by default on all repos)

## Verify Setup

Run this to confirm everything is installed:

```bash
terraform version    # Should print: Terraform v1.5.x or higher
aws --version        # Should print: aws-cli/2.x.x
git --version        # Should print: git version 2.x
go version           # Should print: go1.21.x
pre-commit --version # Should print: pre-commit 3.x.x
checkov --version    # Should print: checkov 3.x.x
tflint --version     # Should print: tflint version 0.5x.x
opa version          # Should print: OPA 0.6x.x
conftest --version   # Should print: conftest 0.4x.x
```

!!! tip "One-line check"
    ```bash
    for cmd in terraform aws git go pre-commit checkov tflint opa conftest; do
      echo -n "$cmd: "; $cmd version 2>/dev/null | head -1 || echo "NOT INSTALLED"
    done
    ```
