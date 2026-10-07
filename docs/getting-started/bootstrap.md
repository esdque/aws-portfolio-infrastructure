---
title: Bootstrap — First Run
description: How to create the S3 bucket, DynamoDB lock table, and KMS key that Terraform needs to operate.
---

# Bootstrap — First Run

The bootstrap is the most important step in the entire platform. It creates the three AWS
resources that Terraform itself depends on. Everything else fails without it.

---

## What Bootstrap Creates

| Resource | AWS Type | Purpose |
|---|---|---|
| `terraform-state-ACCOUNT_ID` | S3 Bucket | Stores all Terraform state files |
| `terraform-locks` | DynamoDB Table | Prevents concurrent Terraform runs |
| `terraform-state-key` | KMS Key | Encrypts state files at rest |

The S3 bucket is configured with:

- ✅ Versioning enabled (30-day recovery window)
- ✅ SSE-KMS encryption (your key, not AWS-managed)
- ✅ Block All Public Access
- ✅ HTTPS-only bucket policy
- ✅ Glacier lifecycle after 90 days (cost control)

---

## The Chicken-and-Egg Problem

Terraform needs S3 to store state — but S3 doesn't exist yet.

**Solution:** Run bootstrap with local state first, then migrate.

```bash
# Phase 1: Local state (S3 doesn't exist yet)
cd terraform/bootstrap
terraform init          # Initialises with local state
terraform plan          # Preview what will be created
terraform apply         # Creates S3, DynamoDB, KMS

# Phase 2: Migrate state to the new S3 bucket
# Edit backend.tf — uncomment the S3 backend block
terraform init -migrate-state   # Terraform asks: "Move state to S3?" → yes
```

After migration, your local `terraform.tfstate` file is empty.
The real state is now in S3 at: `s3://YOUR-BUCKET-NAME/bootstrap/terraform.tfstate`

---

## Verification

After `terraform apply` succeeds, verify each resource in the AWS Console:

**S3 Bucket:**

1. AWS Console → S3 → search for `terraform-state`
2. Confirm bucket exists, region is `ca-central-1`
3. Click the bucket → **Properties** tab
4. Confirm: Versioning = Enabled, Default encryption = SSE-KMS

**DynamoDB Table:**

1. AWS Console → DynamoDB → Tables
2. Find `terraform-locks`
3. Confirm: Status = Active, Billing mode = Pay per request

**KMS Key:**

1. AWS Console → KMS → Customer managed keys
2. Find `terraform-state-key`
3. Confirm: Status = Enabled, Key rotation = Enabled

---

## Evidence

See [Bootstrap Evidence](../evidence/bootstrap.md) for screenshots of each resource
after successful deployment.

---

## Cost

| Resource | Monthly Cost |
|---|---|
| KMS key | $1.00 |
| S3 storage (state files) | ~$0.02 |
| DynamoDB (on-demand) | ~$0.00 |
| **Total** | **~$1.52/month** |

See [Full Cost Analysis](../cost/analysis.md) for breakdown of all module costs.
