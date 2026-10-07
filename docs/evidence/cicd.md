# CI/CD Pipeline Evidence

This page shows the GitHub Actions pipeline running — security scans, plan output on PRs, and successful applies.

---

## Pipeline Overview

Every pull request triggers three parallel jobs:
1. **Security Scan** — Checkov with SARIF output
2. **OPA Policies** — Required tags and security controls
3. **TFLint** — Per-module linting
4. **Format Check** — `terraform fmt -check`

Merges to main trigger the **Terraform Apply** workflow.

---

## PR Check Run

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![GitHub PR showing all CI checks passing with green checkmarks](../../assets/screenshots/cicd/01-pr-checks-passing.png)
*All four CI checks passing on a sample PR*

---

## Terraform Plan as PR Comment

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![GitHub PR comment showing terraform plan output for dev environment](../../assets/screenshots/cicd/02-plan-pr-comment.png)
*Automatic plan comment showing what will change before merging*

---

## Security Scan Results (GitHub Security Tab)

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![GitHub Security tab showing Checkov SARIF findings with severity levels](../../assets/screenshots/cicd/03-security-tab-sarif.png)
*Checkov findings visible in GitHub Security → Code scanning alerts*

---

## OIDC Authentication (No Stored Keys)

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![GitHub Actions log showing OIDC token exchange and temporary credentials](../../assets/screenshots/cicd/04-oidc-auth-log.png)
*Actions log showing role assumption via OIDC — no long-lived keys stored*

---

## Terraform Apply Success

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![GitHub Actions apply job showing terraform apply completing with resources created](../../assets/screenshots/cicd/05-apply-success.png)
*Terraform apply completing on push to main — dev environment deployed*

---

## Apply Job Summary

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![GitHub Actions job summary showing terraform output values](../../assets/screenshots/cicd/06-apply-summary.png)
*Job summary showing VPC ID, subnet IDs, and role ARNs from terraform output*
