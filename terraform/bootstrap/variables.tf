variable "company_name" {
  description = "Short company name used in resource naming (lowercase, no spaces)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID — used to make S3 bucket name globally unique"
  type        = string
}

variable "aws_region" {
  description = "AWS region for all bootstrap resources"
  type        = string
  default     = "ca-central-1"
}

variable "tags" {
  description = "Tags to apply to all bootstrap resources"
  type        = map(string)
  default = {
    ManagedBy   = "terraform"
    Environment = "bootstrap"
    Project     = "iac-platform"
  }
}
