# Terratest — Infrastructure Tests

Integration tests that deploy real AWS resources, validate them, and destroy them.

## Prerequisites

- Go 1.21+
- AWS credentials with PowerUserAccess (or equivalent)
- `ca-central-1` region (matches project defaults)

## Running Tests

```bash
# Install dependencies
cd tests/terratest
go mod tidy

# Run ALL tests (takes 5-15 minutes, creates/destroys real AWS resources)
go test -v -timeout 30m ./...

# Run a single test
go test -v -timeout 15m -run TestVPCModule ./...
go test -v -timeout 15m -run TestIAMModule ./...
```

## Cost Warning

These tests create real AWS resources and **destroy them immediately after**.
The only costs are for the brief time they run (~5 minutes):

| Test         | Resources Created        | Approx Cost |
|--------------|--------------------------|-------------|
| TestVPCModule | VPC, 6 subnets, IGW, S3 endpoint | < $0.01 |
| TestIAMModule | 2 IAM roles, 1 OIDC provider     | $0.00 |

**Always run `terraform destroy` on failure** — if a test fails mid-run, manually
destroy with:

```bash
cd terraform/modules/vpc
terraform destroy -var-file=test.tfvars
```

## CI Integration

Tests run in the `terraform-ci.yml` workflow on PRs that change module code.
They require `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` GitHub secrets
with appropriate permissions.
