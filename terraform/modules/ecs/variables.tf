variable "cluster_name" { type = string; description = "ECS cluster name" }
variable "vpc_id"       { type = string; description = "VPC ID for task security group" }
variable "tags"         { type = map(string); default = {}; description = "Tags for all resources" }
