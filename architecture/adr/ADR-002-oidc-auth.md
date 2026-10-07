# ADR-002: Keyless Authentication with GitHub OIDC

**Status:** Accepted  
**Date:** 2024-01-20  
**Deciders:** Platform Team

---

## Context

GitHub Actions needs AWS credentials to run `terraform plan` and `terraform apply`.
Storing long-lived IAM access keys as GitHub Secrets is a security risk:
- Keys can leak via logs
- Keys don't auto-rotate
- Broad permissions because scope is hard to narrow

## Decision

Use **GitHub's OIDC provider** with short-lived AWS credentials via `sts:AssumeRoleWithWebIdentity`.

Two roles with different trust policies:
1. **Plan role** — `StringLike` condition allows ANY branch (for PR checks)
2. **Apply role** — `StringEquals` condition restricts to `refs/heads/main` ONLY

No long-lived credentials stored anywhere.

## How It Works

```
GitHub Actions Job
    │
    ├─ Requests JWT from GitHub OIDC endpoint
    │
    ├─ Calls sts:AssumeRoleWithWebIdentity with JWT
    │
    └─ Receives 15-minute credentials (never stored)
```

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| IAM access keys in Secrets | Static credentials, rotation burden, leak risk |
| IAM access keys via environment | Same problems |
| AWS Secrets Manager rotation | Still long-lived base credential needed |

## Consequences

✅ **Positive:** No stored credentials, credentials expire in 15 minutes, audit trail in CloudTrail  
✅ **Positive:** If repo is compromised, attacker cannot apply to prod (wrong branch)  
⚠️ **Negative:** OIDC provider is account-wide singleton — only create once  
⚠️ **Negative:** Slightly more complex initial setup
