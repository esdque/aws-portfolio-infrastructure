variable "project_name"                { type = string; description = "Project name prefix" }
variable "aws_region"                   { type = string; description = "AWS region" }
variable "kms_key_id"                   { type = string; description = "KMS key ID for SNS encryption" }
variable "alert_emails"                 { type = list(string); default = []; description = "Email addresses to receive CloudWatch alarms" }
variable "billing_alarm_threshold_usd"  { type = number; default = 50; description = "USD threshold for billing alarm" }
variable "monthly_budget_usd"           { type = number; default = 100; description = "Monthly AWS budget in USD" }
variable "tags"                         { type = map(string); default = {}; description = "Tags for all resources" }
