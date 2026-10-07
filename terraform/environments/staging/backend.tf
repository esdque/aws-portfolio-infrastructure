terraform {
  backend "s3" {
    bucket         = "terraform-state-YOUR_ACCOUNT_ID"
    key            = "environments/staging/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    kms_key_id     = "alias/mycompany-terraform-state"
    dynamodb_table = "terraform-locks"
  }
}
