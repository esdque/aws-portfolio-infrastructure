variable "vpc_name" {
  description = "Name prefix for all VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use (2 for dev/staging, 3 for prod)"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways: 0=dev (saves ~$32/month), 1=staging, az_count=prod (HA)"
  type        = number
  default     = 1

  validation {
    condition     = var.nat_gateway_count >= 0 && var.nat_gateway_count <= 3
    error_message = "nat_gateway_count must be between 0 and 3."
  }
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch (recommended for prod, optional for dev)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
