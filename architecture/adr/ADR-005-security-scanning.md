# ADR-005: Multi-Layer Security Scanning in CI

**Status:** Accepted  
**Date:** 2024-02-01  
**Deciders:** Platform Team

---

## Context

Infrastructure code carries security risk. We need automated scanning that catches issues before they reach AWS.

## Decision

Three complementary tools running in every PR:

| Tool | Purpose | Blocks PR? |
|------|---------|-----------|
| **Checkov** | 1000+ security rules, SARIF to GitHub Security tab | Soft fail (visibility) |
| **TFLint** | AWS-specific validation, naming conventions | Hard fail |
| **OPA/Conftest** | Custom business policies (required tags, thresholds) | Hard fail |

Checkov uses soft-fail because some rules produce false positives for valid configurations. The SARIF output still surfaces findings in the GitHub Security tab for review.

TFLint and OPA are hard failures because they check our own policies, which we control.

## Alternatives Considered

| Option | Considered? | Decision |
|--------|------------|---------|
| Terrascan | Yes | Checkov covers more AWS rules |
| Snyk IaC | Yes | Paid, not necessary for portfolio |
| tfsec | Yes | Merged into Checkov |
| Manual review only | No | Doesn't scale |

## Consequences

✅ **Positive:** Security findings visible to team without blocking development  
✅ **Positive:** Custom policies enforce team standards (tags, encryption)  
✅ **Positive:** SARIF integration means findings appear in GitHub Security tab  
⚠️ **Negative:** CI pipeline is slower (~3-5 minutes for scans)  
⚠️ **Negative:** OPA policies require maintaining .rego files
