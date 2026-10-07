output "db_instance_id"       { value = aws_db_instance.main.id; description = "RDS instance ID" }
output "db_endpoint"          { value = aws_db_instance.main.endpoint; description = "Connection endpoint (host:port)" }
output "db_host"              { value = aws_db_instance.main.address; description = "RDS hostname" }
output "db_port"              { value = aws_db_instance.main.port; description = "RDS port" }
output "db_name"              { value = aws_db_instance.main.db_name; description = "Database name" }
output "security_group_id"    { value = aws_security_group.rds.id; description = "RDS security group ID" }
output "subnet_group_name"    { value = aws_db_subnet_group.main.name; description = "DB subnet group name" }
