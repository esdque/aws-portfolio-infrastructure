output "security_group_id"    { value = aws_security_group.ec2.id; description = "EC2 security group ID" }
output "launch_template_id"   { value = aws_launch_template.main.id; description = "Launch template ID" }
output "asg_name"             { value = aws_autoscaling_group.main.name; description = "Auto Scaling Group name" }
output "instance_profile_arn" { value = aws_iam_instance_profile.ec2.arn; description = "IAM instance profile ARN" }
output "iam_role_arn"         { value = aws_iam_role.ec2.arn; description = "IAM role ARN for EC2 instances" }
