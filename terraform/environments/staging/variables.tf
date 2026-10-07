variable "aws_region"        { type = string; default = "ca-central-1" }
variable "project_name"      { type = string }
variable "owner_email"       { type = string }
variable "vpc_cidr"          { type = string; default = "10.20.0.0/16" }
variable "github_org"        { type = string }
variable "github_repo"       { type = string }
variable "state_bucket_name" { type = string }
variable "lock_table_name"   { type = string }
variable "kms_key_arn"       { type = string }
variable "kms_key_id"        { type = string }
variable "alert_emails"      { type = list(string); default = [] }
