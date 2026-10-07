# Bootstrap Evidence

This page documents the bootstrap phase — creating the S3 bucket, DynamoDB table, and KMS key that store all Terraform state.

---

## What Was Deployed

Running `terraform apply` in `terraform/bootstrap/` creates:

- `aws_s3_bucket.terraform_state` — versioned, KMS-encrypted, public access blocked
- `aws_dynamodb_table.terraform_locks` — PAY_PER_REQUEST, deletion protection enabled
- `aws_kms_key.terraform_state` — customer-managed, annual rotation, 30-day deletion window
- `aws_kms_alias.terraform_state` — human-readable alias

---

## Terminal Output

```bash
$ cd terraform/bootstrap
$ terraform init
$ terraform apply -auto-approve
```

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![Bootstrap terminal output showing terraform apply completing successfully](../../assets/screenshots/bootstrap/01-terraform-apply-output.png)
*Terraform apply completing with all 9 resources created*

---

## S3 Bucket Verification

In AWS Console → S3 → `terraform-state-{account-id}`:

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![S3 bucket console showing versioning enabled and encryption settings](../../assets/screenshots/bootstrap/02-s3-bucket-properties.png)
*Bucket showing: Versioning Enabled, SSE-KMS encryption, Block Public Access all green*

**What to verify:**
- ✅ Bucket versioning: Enabled
- ✅ Default encryption: AWS KMS (customer managed key)
- ✅ Block public access: All four settings ON
- ✅ Bucket policy: HTTPS-only (deny HTTP)

---

## DynamoDB Lock Table

In AWS Console → DynamoDB → Tables → `terraform-locks`:

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![DynamoDB table showing LockID primary key and deletion protection](../../assets/screenshots/bootstrap/03-dynamodb-table.png)
*Table showing PAY_PER_REQUEST billing, LockID hash key, deletion protection ON*

---

## KMS Key

In AWS Console → KMS → Customer managed keys → `mycompany-terraform-state`:

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![KMS key console showing annual rotation enabled and key policy](../../assets/screenshots/bootstrap/04-kms-key.png)
*Key showing: Status Enabled, Key rotation Enabled, 30-day pending deletion window*

---

## Terraform Outputs

```bash
$ terraform output
kms_key_arn     = "arn:aws:kms:ca-central-1:123456789012:key/abc-123..."
kms_key_id      = "abc-123-def-456-..."
lock_table_name = "terraform-locks"
state_bucket_arn  = "arn:aws:s3:::terraform-state-123456789012"
state_bucket_name = "terraform-state-123456789012"
```

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![Terraform output command showing all five output values](../../assets/screenshots/bootstrap/05-terraform-outputs.png)

---

## State Migration (Phase 2)

After bootstrap, we migrate the local state to the S3 bucket:

```bash
# Uncomment the backend block in backend.tf, then:
terraform init -migrate-state
# Answer YES when prompted
```

<!-- REPLACE WITH ACTUAL SCREENSHOT -->
![terraform init -migrate-state showing successful state migration to S3](../../assets/screenshots/bootstrap/06-state-migration.png)
*State successfully migrated — now stored in S3 with DynamoDB locking*
