variable "name"              { type = string; description = "Name prefix for all EC2 resources" }
variable "vpc_id"            { type = string; description = "VPC to launch instances into" }
variable "subnet_ids"        { type = list(string); description = "Private app subnet IDs for the ASG" }
variable "ami_id"            { type = string; description = "AMI ID (use aws_ami data source in calling module)" }
variable "instance_type"     { type = string; default = "t3.micro"; description = "EC2 instance type" }
variable "root_volume_size_gb" { type = number; default = 20; description = "Root EBS volume size in GB" }
variable "min_size"          { type = number; default = 1; description = "ASG minimum size" }
variable "max_size"          { type = number; default = 3; description = "ASG maximum size" }
variable "desired_capacity"  { type = number; default = 1; description = "ASG desired capacity" }
variable "user_data_base64"  { type = string; default = null; description = "Base64-encoded user data script" }
variable "tags"              { type = map(string); default = {}; description = "Tags for all resources" }
