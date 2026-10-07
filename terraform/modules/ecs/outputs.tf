output "cluster_id"              { value = aws_ecs_cluster.main.id; description = "ECS cluster ID" }
output "cluster_name"            { value = aws_ecs_cluster.main.name; description = "ECS cluster name" }
output "cluster_arn"             { value = aws_ecs_cluster.main.arn; description = "ECS cluster ARN" }
output "task_execution_role_arn" { value = aws_iam_role.task_execution.arn; description = "Task execution role ARN" }
output "task_role_arn"           { value = aws_iam_role.task.arn; description = "Task role ARN (attach app-specific policies here)" }
output "task_security_group_id"  { value = aws_security_group.tasks.id; description = "Default ECS task security group ID" }
output "log_group_name"          { value = aws_cloudwatch_log_group.ecs.name; description = "CloudWatch log group for ECS tasks" }
