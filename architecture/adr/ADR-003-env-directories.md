# ADR-003: Environment Isolation via Directories (Not Workspaces)

**Status:** Accepted  
**Date:** 2024-01-22  
**Deciders:** Platform Team

---

## Context

Terraform provides two ways to manage multiple environments: workspaces and separate directories.

## Decision

Use **separate directories** for each environment (`environments/dev`, `environments/staging`, `environments/production`).

Each directory has its own:
- `main.tf` with environment-specific module calls
- `backend.tf` with a unique state key
- `terraform.tfvars` with environment-specific values

## Why Not Workspaces?

Terraform workspaces share the same backend configuration and are easy to confuse.
A developer on `prod` workspace running `apply` has caused many real-world incidents.

Directories make it physically impossible to accidentally apply to prod:
- You must `cd` to the right directory
- CI/CD has separate jobs per directory
- The backend key is hardcoded in `backend.tf`

## Consequences

✅ **Positive:** Maximum blast-radius isolation  
✅ **Positive:** Each environment can diverge in configuration (prod has 3 NAT gateways, dev has 0)  
✅ **Positive:** Clear mental model — one directory = one environment  
⚠️ **Negative:** Some code duplication (mitigated by modules)  
⚠️ **Negative:** Cannot use `terraform workspace select` — must use `cd`
