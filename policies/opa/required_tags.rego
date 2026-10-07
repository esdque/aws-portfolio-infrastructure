package main

# Required tags that EVERY taggable resource must have
required_tags := ["Environment", "Project", "ManagedBy", "Owner"]

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] != "delete"

  # Only check resources that support tags
  resource.type != "aws_iam_role_policy"
  resource.type != "aws_iam_role_policy_attachment"
  resource.type != "aws_route_table_association"
  resource.type != "aws_s3_bucket_policy"
  resource.type != "aws_s3_bucket_versioning"
  resource.type != "aws_s3_bucket_server_side_encryption_configuration"
  resource.type != "aws_s3_bucket_public_access_block"
  resource.type != "aws_s3_bucket_lifecycle_configuration"
  resource.type != "aws_db_subnet_group"

  tags := resource.change.after.tags
  required_tag := required_tags[_]
  not tags[required_tag]

  msg := sprintf(
    "Resource '%s' (%s) is missing required tag '%s'",
    [resource.address, resource.type, required_tag]
  )
}

# ManagedBy must always be "terraform"
deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] != "delete"
  tags := resource.change.after.tags
  tags["ManagedBy"] != "terraform"

  msg := sprintf(
    "Resource '%s' has ManagedBy='%s' but must be 'terraform'",
    [resource.address, tags["ManagedBy"]]
  )
}
