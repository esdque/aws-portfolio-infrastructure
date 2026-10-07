# Module Outputs Evidence

This page shows the VPC, IAM, and other modules running successfully with actual AWS resources.

---

## VPC Module

### AWS Console — VPC Overview

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS VPC console showing the three-tier VPC with subnets listed](../../assets/screenshots/modules/01-vpc-overview.png)
*VPC overview showing CIDR block, DNS hostnames enabled, and all 6 subnets*

### Subnet Layout

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS Subnets console showing public, private-app, and private-data subnets across two AZs](../../assets/screenshots/modules/02-subnets.png)
*Six subnets: 2 public (Tier=public tag), 2 private-app, 2 private-data — each in a separate AZ*

### Route Tables

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS Route Tables console showing public route to IGW and private route to NAT](../../assets/screenshots/modules/03-route-tables.png)
*Public route table routes 0.0.0.0/0 → Internet Gateway; private route table routes 0.0.0.0/0 → NAT Gateway*

### S3 VPC Endpoint

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS VPC Endpoints console showing S3 Gateway endpoint status as Available](../../assets/screenshots/modules/04-s3-endpoint.png)
*S3 Gateway endpoint — keeps S3 traffic off the internet, no additional cost*

---

## IAM Module

### GitHub OIDC Provider

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS IAM Identity Providers console showing GitHub OIDC provider](../../assets/screenshots/modules/05-oidc-provider.png)
*OIDC provider for token.actions.githubusercontent.com registered in IAM*

### Plan Role Trust Policy

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS IAM Role trust policy showing StringLike condition for any branch](../../assets/screenshots/modules/06-plan-role-trust.png)
*Plan role trust policy: StringLike allows any branch (for PRs)*

### Apply Role Trust Policy

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS IAM Role trust policy showing StringEquals condition for main branch only](../../assets/screenshots/modules/07-apply-role-trust.png)
*Apply role trust policy: StringEquals restricts to refs/heads/main ONLY*

---

## VPC Flow Logs (Staging/Production)

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![AWS CloudWatch Log Groups showing VPC flow log entries](../../assets/screenshots/modules/08-flow-logs.png)
*Flow logs streaming to CloudWatch — captures all accepted/rejected traffic*
