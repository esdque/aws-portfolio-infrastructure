# Evidence Gallery

This section contains visual proof that Project 19 actually works — not just code, but running infrastructure.

!!! tip "Why Evidence Matters"
    Any candidate can copy-paste Terraform code. Evidence pages show you ran it, debugged it, and understand what it produces. This is what separates your portfolio from AI-generated repositories.

---

## Evidence Summary

| Category | What You'll See | Status |
|----------|----------------|--------|
| [Bootstrap](bootstrap.md) | S3 bucket, DynamoDB table, KMS key in AWS Console | 📸 Screenshots |
| [CI/CD Pipeline](cicd.md) | GitHub Actions runs, security scan results, SARIF output | 📸 + 🎥 |
| [Module Outputs](modules.md) | VPC subnets, route tables, OIDC provider, flow logs | 📸 Screenshots |
| [Cost Analysis](../cost/analysis.md) | AWS Cost Explorer showing actual charges | 📸 Screenshot |

---

## How to Read This Evidence

Each evidence page follows a consistent format:

1. **What was deployed** — the Terraform resources
2. **Console verification** — AWS Console screenshots confirming resources exist
3. **Terraform output** — actual command output showing what was created
4. **Key verification points** — what to look for to prove correctness

---

## Recording Date

All evidence was captured after a clean `terraform apply` from scratch in a fresh AWS account.
