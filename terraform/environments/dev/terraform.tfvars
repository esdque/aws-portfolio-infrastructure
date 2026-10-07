# ── Dev Environment Configuration ────────────────────────────────────────────
# Replace placeholder values before running terraform apply
aws_region   = "ca-central-1"
project_name = "esdque-iac"
owner_email  = "hassansodiqabu@gmail.com"
vpc_cidr     = "10.10.0.0/16"

# GitHub (for OIDC role trust policy)
github_org  = "esdque"
github_repo = "aws-portfolio-infrastructure"

# State backend (output from bootstrap)
create_oidc_provider = true
state_bucket_name    = "terraform-state-123456789012"
lock_table_name      = "terraform-locks"
kms_key_arn          = "arn:aws:kms:ca-central-1:123456789012:key/YOUR-KMS-KEY-ID"
kms_key_id           = "alias/mycompany-terraform-state"

alert_emails = ["you@example.com"]
