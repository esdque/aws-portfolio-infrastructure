variable "identifier"                   { type = string; description = "RDS instance identifier" }
variable "vpc_id"                       { type = string; description = "VPC ID" }
variable "subnet_ids"                   { type = list(string); description = "Private data subnet IDs" }
variable "allowed_security_group_ids"   { type = list(string); description = "Security groups allowed to connect (e.g. EC2/ECS task SGs)" }
variable "engine"                       { type = string; default = "postgres"; description = "DB engine" }
variable "engine_version"               { type = string; default = "15.4"; description = "Engine version" }
variable "instance_class"               { type = string; default = "db.t3.micro"; description = "RDS instance class" }
variable "allocated_storage_gb"         { type = number; default = 20; description = "Allocated storage in GB" }
variable "kms_key_arn"                  { type = string; description = "KMS key ARN for storage encryption" }
variable "db_name"                      { type = string; description = "Initial database name" }
variable "db_username"                  { type = string; description = "Master username" }
variable "db_password"                  { type = string; sensitive = true; description = "Master password (use Secrets Manager in prod)" }
variable "db_port"                      { type = number; default = 5432; description = "Database port" }
variable "multi_az"                     { type = bool; default = false; description = "Enable Multi-AZ for HA" }
variable "deletion_protection"          { type = bool; default = false; description = "Enable deletion protection (true for prod)" }
variable "backup_retention_days"        { type = number; default = 7; description = "Automated backup retention period" }
variable "enable_performance_insights"  { type = bool; default = false; description = "Enable RDS Performance Insights" }
variable "tags"                         { type = map(string); default = {}; description = "Tags for all resources" }
