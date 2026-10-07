variable "project_name" {
  description = "Short project name used in role naming (e.g. mycompany-iac)"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or username (e.g. my-org)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (e.g. aws-portfolio-infrastructure)"
  type        = string
}

variable "create_oidc_provider" {
  description = "Set true to create the GitHub OIDC provider. False if it already exists in the account."
  type        = bool
  default     = true
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state (for scoped IAM policies)"
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB lock table (for scoped IAM policies)"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key encrypting state (for scoped IAM policies)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}
