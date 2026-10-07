# ADR-004: Three-Tier VPC Architecture

**Status:** Accepted  
**Date:** 2024-01-25  
**Deciders:** Platform Team

---

## Context

We need a network architecture that can host web applications with web, application, and database layers requiring different security postures.

## Decision

Three-tier subnet architecture across multiple availability zones:

| Tier | Access | Hosts |
|------|--------|-------|
| **Public** | Internet via IGW | Load balancers, NAT gateways |
| **Private App** | Internet via NAT | EC2, ECS tasks, EKS nodes |
| **Private Data** | VPC only | RDS, ElastiCache |

CIDR allocation uses `/20` blocks from the VPC `/16`:
- Public: `10.x.0.0/20`, `10.x.16.0/20`, `10.x.32.0/20`
- Private App: `10.x.64.0/20`, `10.x.80.0/20`, `10.x.96.0/20`
- Private Data: `10.x.128.0/20`, `10.x.144.0/20`, `10.x.160.0/20`

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| Single public subnet | No defense-in-depth, fails compliance |
| Two-tier (public + private) | Combines app and data security domains |
| PrivateLink everywhere | Excessive complexity for portfolio scope |

## Consequences

✅ **Positive:** Aligns with AWS Well-Architected Framework  
✅ **Positive:** Data layer cannot be reached from internet under any routing config  
✅ **Positive:** Variable NAT gateway count (0=dev, 1=staging, 3=prod) controls cost  
⚠️ **Negative:** 9 subnets per environment (manageable with count meta-argument)
