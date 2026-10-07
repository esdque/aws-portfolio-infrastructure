# =============================================================================
# Bootstrap backend configuration
#
# PHASE 1 (first run): Leave this file as-is. Terraform uses LOCAL state.
#
# PHASE 2 (after apply): Uncomment the terraform block below, then run:
#   terraform init -migrate-state
# Terraform will ask: "Do you want to copy existing state?" — answer YES.
# =============================================================================

# Uncomment after terraform apply creates the S3 bucket:
#
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-YOUR_ACCOUNT_ID"
#     key            = "bootstrap/terraform.tfstate"
#     region         = "ca-central-1"
#     encrypt        = true
#     kms_key_id     = "alias/mycompany-terraform-state"
#     dynamodb_table = "terraform-locks"
#   }
# }
