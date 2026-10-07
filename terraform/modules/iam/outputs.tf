output "plan_role_arn" {
  description = "ARN of the GitHub Actions PLAN role (any branch)"
  value       = aws_iam_role.github_plan.arn
}

output "plan_role_name" {
  description = "Name of the GitHub Actions PLAN role"
  value       = aws_iam_role.github_plan.name
}

output "apply_role_arn" {
  description = "ARN of the GitHub Actions APPLY role (main branch only)"
  value       = aws_iam_role.github_apply.arn
}

output "apply_role_name" {
  description = "Name of the GitHub Actions APPLY role"
  value       = aws_iam_role.github_apply.name
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider"
  value       = local.oidc_provider_arn
}
