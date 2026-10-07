# ADR-001: Remote State with S3 + DynamoDB

**Status:** Accepted  
**Date:** 2024-01-15  
**Deciders:** Platform Team

---

## Context

Terraform state files contain sensitive information (resource IDs, IP addresses, sometimes secrets) and must be:
- Shared across team members and CI/CD pipelines
- Protected against concurrent modifications (state corruption)
- Encrypted at rest
- Versioned for recovery

Local state fails all of these requirements.

## Decision

Use **AWS S3** for state storage with **DynamoDB** for state locking.

- S3 bucket with versioning + SSE-KMS encryption (customer-managed key)
- DynamoDB table with LockID hash key for pessimistic locking
- Separate state keys per environment: `environments/{env}/terraform.tfstate`
- Bootstrap state stored at: `bootstrap/terraform.tfstate`

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| Terraform Cloud | Vendor lock-in, cost for teams > 5 |
| GitLab-managed state | Not using GitLab |
| Local state | No collaboration, no CI/CD |
| HashiCorp Consul | Operational overhead |

## Consequences

✅ **Positive:** Standard AWS pattern, no additional vendor, encrypted, versioned  
⚠️ **Negative:** Chicken-and-egg bootstrap problem (solved by Phase 1/Phase 2 migration)  
⚠️ **Negative:** S3 + KMS + DynamoDB cost ~$1.52/month (acceptable)
