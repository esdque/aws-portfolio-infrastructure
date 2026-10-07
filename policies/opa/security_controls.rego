package main

# ── S3 Buckets must have encryption enabled ──────────────────────────────────
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  resource.change.actions[_] != "delete"
  not resource.change.after.server_side_encryption_configuration

  msg := sprintf(
    "S3 bucket '%s' must have server-side encryption configured",
    [resource.address]
  )
}

# ── RDS instances must be encrypted ──────────────────────────────────────────
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_db_instance"
  resource.change.actions[_] != "delete"
  not resource.change.after.storage_encrypted

  msg := sprintf(
    "RDS instance '%s' must have storage_encrypted = true",
    [resource.address]
  )
}

# ── RDS must not be publicly accessible ──────────────────────────────────────
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_db_instance"
  resource.change.actions[_] != "delete"
  resource.change.after.publicly_accessible

  msg := sprintf(
    "RDS instance '%s' must have publicly_accessible = false",
    [resource.address]
  )
}

# ── EC2 instances must require IMDSv2 ────────────────────────────────────────
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_launch_template"
  resource.change.actions[_] != "delete"
  metadata := resource.change.after.metadata_options[_]
  metadata.http_tokens != "required"

  msg := sprintf(
    "Launch template '%s' must set metadata_options.http_tokens = 'required' (IMDSv2)",
    [resource.address]
  )
}

# ── VPCs must not use the default 0.0.0.0/0 CIDR for overly broad ranges ─────
warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group_rule"
  resource.change.after.cidr_blocks[_] == "0.0.0.0/0"
  resource.change.after.type == "ingress"

  msg := sprintf(
    "Security group rule '%s' allows ingress from 0.0.0.0/0 — review if intentional",
    [resource.address]
  )
}

# ── NAT gateway count for production must be >= 2 ────────────────────────────
warn[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_nat_gateway"
  resource.change.after.tags.Environment == "production"
  count([r | r := input.resource_changes[_]; r.type == "aws_nat_gateway"]) < 2

  msg := "Production environment should have at least 2 NAT gateways for HA"
}
