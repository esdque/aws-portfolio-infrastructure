# =============================================================================
# terraform/bootstrap/main.tf
# =============================================================================
# PURPOSE: Create the S3 bucket, DynamoDB lock table, and KMS key that
# Terraform needs to store and manage state files.
#
# RUN ORDER: This is run FIRST — before any module, before any environment.
# Without this, Terraform has nowhere to store its state.
#
# CHICKEN-AND-EGG SOLUTION:
#   1. Run with local state: terraform init && terraform apply
#   2. Migrate to S3:        terraform init -migrate-state
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

# ─── KMS Key ──────────────────────────────────────────────────────────────────
# Encrypts everything in the S3 bucket. $1/month. Non-negotiable for production.
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption — ${var.company_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM permissions"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.aws_account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Deny key deletion by non-root"
        Effect = "Deny"
        Principal = { AWS = "*" }
        Action   = ["kms:ScheduleKeyDeletion", "kms:DeleteImportedKeyMaterial"]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${var.aws_account_id}:root"
          }
        }
      }
    ]
  })

  tags = { Name = "${var.company_name}-terraform-state-key" }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.company_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# ─── S3 Bucket ────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state-${var.aws_account_id}"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = { Name = "terraform-state-${var.aws_account_id}" }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    id     = "transition-old-versions"
    status = "Enabled"
    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }
    noncurrent_version_expiration { noncurrent_days = 365 }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyNonHTTPS"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [
        aws_s3_bucket.terraform_state.arn,
        "${aws_s3_bucket.terraform_state.arn}/*"
      ]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}

# ─── DynamoDB Lock Table ───────────────────────────────────────────────────────
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery { enabled = true }
  deletion_protection_enabled = true

  tags = { Name = "terraform-locks" }
}
