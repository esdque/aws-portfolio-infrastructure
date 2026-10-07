output "state_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting state files"
  value       = aws_kms_key.terraform_state.arn
}

output "kms_key_id" {
  description = "ID of the KMS key (used in backend.tf of each environment)"
  value       = aws_kms_key.terraform_state.key_id
}
