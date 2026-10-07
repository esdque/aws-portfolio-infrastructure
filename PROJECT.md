# PROJECT 19: Enterprise Infrastructure-as-Code Platform
**Build Order:** 1 of 30 — This project is deployed FIRST because every other project in this portfolio depends on it.

---

# ⚠️ AI SENIOR CLOUD ENGINEER OPERATING CONTRACT

Before we begin, these rules govern how every session on this project must operate.
Read them now. Refer back whenever something feels unclear.

| Rule | What It Means |
|------|---------------|
| **Rule 1 — Never assume knowledge** | If a concept hasn't been explained, it gets explained before use. No exceptions. |
| **Rule 2 — Never skip reasoning** | Before any command: explain WHY. Before any resource: explain WHAT it does. |
| **Rule 3 — Never give unexplained commands** | Every command shows: purpose, syntax breakdown, expected output, success criteria, common errors. |
| **Rule 4 — One logical step at a time** | Never hand over 20 commands at once. Each step builds on the verified previous step. |
| **Rule 5 — Verification is mandatory** | Every major step has a verification. **STOP. DO NOT CONTINUE until verification passes.** |
| **Rule 6 — Explain alternatives** | For major decisions: explain at least two alternatives and why we chose what we chose. |
| **Rule 7 — Identify blind spots** | Tell me what a senior engineer would notice that a beginner would miss. |
| **Rule 8 — Teach failure** | Don't only show the happy path. Show what breaks and why. |
| **Rule 9 — Teach operations** | Everything deployed must be monitored, secured, backed up, and recoverable. |
| **Rule 10 — Teach cost** | Explain what costs money, how much, and what the cost driver is. |
| **Rule 11 — Prefer IaC** | The final architecture must be reproducible from Git with one command. |
| **Rule 12 — Use Git professionally** | Commits are logical. PRs have meaningful descriptions. Branches follow a naming convention. |
| **Rule 13 — Document while building** | Don't wait until the end. Write evidence as you go. |
| **Rule 14 — Challenge my decisions** | Don't automatically agree. If I propose something wrong, say so and explain why. |
| **Rule 15 — Don't hide mistakes** | If something breaks: document what happened, why, how we diagnosed it, and how we fixed it. |
| **Rule 16 — Don't let me memorize blindly** | Ask me to explain concepts back before we proceed. |
| **Rule 17 — Connect to certification** | Every task maps to a SAA-C03, SOA-C03, or DOP-C02 objective. |
| **Rule 18 — Connect to employment** | Every task maps to an interview competency. |
| **Rule 19 — Stop at checkpoints** | Give me time to test myself before moving on. |
| **Rule 20 — Never declare "production ready" without evidence** | Evidence required: security review, resilience test, monitoring, backup/recovery, cost review, IaC, documentation. |

---

# PART I — PROJECT ORIENTATION

## 1. Project Identity

```
Project:              Enterprise Infrastructure-as-Code (IaC) Platform
Project Number:       19
Build Order:          1 (deployed before any other project)
Difficulty:           Advanced
Status:               [ ] Not Started  [ ] In Progress  [ ] Complete  [ ] Documented

Primary AWS Domains:
  - DevOps & Automation
  - Security & Compliance
  - Cost Governance
  - Operations

Primary Certifications:
  - DOP-C02  (DevOps Engineer Professional)
  - SOA-C03  (SysOps Administrator Associate)
  - SAA-C03  (Solutions Architect Associate)

AWS Services Used:
  - S3                (remote state storage)
  - DynamoDB          (state locking)
  - IAM               (least-privilege roles for CI/CD)
  - KMS               (state encryption)
  - CloudTrail        (audit who ran what Terraform)
  - GitHub Actions    (CI/CD pipeline — not an AWS service, but integral)

IaC Technology:       Terraform >= 1.5
CI/CD:                GitHub Actions
Application:          None — this project IS the infrastructure platform
Treatment:            Full Live Build (bootstrap only) + Module Library Design

Repository:           [YOUR GITHUB URL HERE]
Live Demo:            N/A
Estimated Duration:   2–3 weeks
Estimated AWS Cost:   $1–3/month (S3 + DynamoDB + KMS only)
```

---

# PART II — THE BUSINESS PROBLEM

## 2. Business Scenario

> A Canadian technology company is growing from 5 engineers to 50. Their infrastructure is
> currently managed by clicking around the AWS Console. Nobody knows exactly what resources
> exist, who created them, or why. Deleting one thing breaks another. New environments take
> days to set up. Developers cannot reproduce the production environment locally for testing.
> There is no audit trail. Costs are unpredictable. The CTO has issued a directive:
> **all infrastructure must be code, reviewed, versioned, and automatically deployed.**
> No more clicking. No more snowflake environments.

### What "snowflake environment" means
A snowflake environment is one that is unique and cannot be reproduced. Like a snowflake,
no two are alike. It was built by hand, one click at a time, by someone who may no longer
work there. It is the single biggest source of operational risk in cloud engineering.

### Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-001 | All infrastructure must be defined in code (Terraform) |
| FR-002 | Infrastructure code must live in Git version control |
| FR-003 | Changes must go through a pull request review process |
| FR-004 | Automated checks must run on every pull request |
| FR-005 | Terraform plan must be generated and reviewed before apply |
| FR-006 | Terraform state must be stored remotely, not on a local laptop |
| FR-007 | Only one person/process may modify state at a time (locking) |
| FR-008 | Infrastructure modules must be reusable across environments |
| FR-009 | Dev, staging, and production environments must be isolated |
| FR-010 | Security scanning must run automatically on every change |
| FR-011 | Policy violations must block deployment automatically |
| FR-012 | All state files must be encrypted at rest |

### Non-Functional Requirements

| Property | Requirement |
|----------|-------------|
| Availability | CI/CD pipeline must succeed 99%+ of the time |
| Security | State files encrypted with KMS; IAM least-privilege for CI/CD |
| Auditability | CloudTrail captures who ran Terraform and when |
| Reproducibility | Any environment can be rebuilt from Git in under 30 minutes |
| Cost | Platform overhead under $10/month |

---

# PART III — REQUIREMENTS ANALYSIS

## 3. What Are We Actually Solving?

### A. The Core Problem (in plain English)

Without this project, every other project in this portfolio would be:
- Built by clicking in the AWS Console (no repeatability)
- Impossible to review (no code = no pull requests)
- Impossible to audit (no code = no record of decisions)
- Impossible to version (no code = no history)
- Impossible to share (only you know how to rebuild it)

**This project solves all of that.** It creates the foundation — the toolbox, the pipeline,
the conventions — that all 30 projects will use.

### B. Technical Requirements

1. **Remote state** — Terraform stores its state file in S3, not on a local laptop.
   WHY: If your laptop dies, the state file (which tracks what Terraform created) is gone.
   Without it, Terraform loses track of your infrastructure. This is catastrophic in production.

2. **State locking** — DynamoDB prevents two people from running Terraform simultaneously.
   WHY: If two engineers run `terraform apply` at the same time, they corrupt the state file.
   This can destroy production infrastructure without warning.

3. **Reusable modules** — Terraform code packaged so it can be used in dev, staging, and prod.
   WHY: Without modules, you copy-paste Terraform code for each environment. When you fix
   a bug in the VPC code, you must fix it in three places instead of one.

4. **CI/CD pipeline** — GitHub Actions automates validation, planning, and deployment.
   WHY: Humans make mistakes. Automation catches them before they reach production.

### C. Constraints

| Constraint | Detail |
|------------|--------|
| Budget | Under $10/month for the platform itself |
| Terraform version | >= 1.5 |
| AWS provider | hashicorp/aws ~> 5.0 |
| GitHub | Repository must be GitHub (GitHub Actions CI/CD) |
| Single AWS account | All 30 projects use one AWS account (cost constraint) |
| Region | ca-central-1 (Canadian company; data residency) |

### D. Assumptions and What Happens If They Are Wrong

| Assumption | Impact if False |
|------------|-----------------|
| Single AWS account for all projects | If multi-account: need cross-account S3 bucket policies, assume-role in CI/CD |
| GitHub as the VCS | If GitLab/Azure DevOps: replace GitHub Actions with equivalent |
| Terraform as IaC | If CDK/CloudFormation: entire module library changes |
| Single region (ca-central-1) | If multi-region: S3 replication, DynamoDB global tables |
| One team | If contractors: separate accounts, tighter IAM, no shared state |

---

# PART IV — LEARNING OBJECTIVES

## 4. What You Will Be Able to Do After This Project

**Core ability:** Stand up the infrastructure foundation for any AWS environment
in under 30 minutes, from zero, using only Git and a terminal.

### Specific Objectives — By completing this project I can:

1. Explain what Terraform is and why it exists
2. Explain what "state" means in Terraform and why it matters
3. Explain what remote state is and why local state is dangerous
4. Explain what state locking is and what happens without it
5. Explain what a Terraform module is and why we use them
6. Explain the difference between a module and a root module
7. Explain what `terraform init`, `plan`, `apply`, and `destroy` do — step by step
8. Explain what a CI/CD pipeline is and why we use one for infrastructure
9. Write a complete VPC module from scratch
10. Write a complete IAM module from scratch
11. Set up remote state with S3 and DynamoDB
12. Set up a GitHub Actions pipeline that validates, plans, and applies Terraform
13. Set up security scanning (Checkov) and explain every finding it produces
14. Set up policy enforcement (OPA/Conftest) and write a policy from scratch
15. Create three isolated environments (dev, staging, production) from one module
16. Explain the difference between input variables, local values, and outputs
17. Explain what `terraform.tfvars` is and how it differs from `variables.tf`
18. Debug a state conflict and recover from it safely
19. Explain every line in a GitHub Actions workflow YAML file
20. Explain this entire architecture in a 10-minute technical interview

### Certification Objectives Covered

| Certification | Domains Covered |
|---------------|-----------------|
| DOP-C02 | SDLC Automation, Configuration Management, IaC, CI/CD, Monitoring |
| SOA-C03 | Deployment, Provisioning, Automation, Monitoring, Cost |
| SAA-C03 | Resilient Architectures, Security, Cost Optimization |

---

# PART V — PREREQUISITE KNOWLEDGE

## 5. What You Must Know Before Starting

> **THE RULE:** If you encounter anything in this list that you cannot explain in your
> own words — STOP. Ask the AI to teach it to you first. Never allow the AI to use
> a concept it has not explained.

### Tier 1 — Must Know Before Day 1 (teach yourself or ask now)

**What is a command line / terminal?**
A text-based interface where you type commands instead of clicking buttons.
On Windows: use Windows Terminal or PowerShell.
Every Terraform command will be typed here.

**What is a file path?**
The address of a file on your computer.
Windows example: `C:\Users\hassan\project\main.tf`
Linux/Mac example: `/home/hassan/project/main.tf`
A path tells your computer exactly where a file lives.

**What is a text editor?**
A program for writing code. We use VS Code. NOT Notepad. NOT Word. NOT WordPad.
VS Code understands code — it highlights syntax, catches typos, and integrates with Git.

**What is Git?**
A version control system. Think of it as a time machine for your code files.
Every change you make is recorded as a "commit" — a snapshot with a timestamp and message.
Key commands:
- `git init` — start tracking a folder
- `git add filename` — stage a file to be committed
- `git commit -m "message"` — save a snapshot with a description
- `git push` — upload your commits to GitHub
- `git pull` — download changes from GitHub

**What is GitHub?**
A website that stores Git repositories online. It is where your code lives in the cloud.
It is also where your CI/CD pipeline (GitHub Actions) runs automatically.

**What is a terminal command?**
A text instruction you type into the command line. Example:
```
terraform init
```
Breaking this down:
- `terraform` — the name of the program you are running
- `init` — the specific instruction (subcommand) you are giving it

### Tier 2 — Must Know Before Week 1

**What is AWS?**
Amazon Web Services. A platform that lets you rent computing resources on demand.
Servers, storage, databases, networking — all available by the minute.
You pay only for what you use and only while you use it.

**What is a region?**
AWS has data centers around the world, grouped into geographic regions.
`ca-central-1` is in Canada (Montreal). Every resource you create exists in a specific region.
You choose the region based on: where your users are, data residency laws, and cost.

**What is IAM?**
Identity and Access Management. AWS's system for controlling WHO can do WHAT.
- A **user** is a person identity (your AWS login)
- A **role** is a set of permissions that can be assumed temporarily by a service
- A **policy** is a JSON document listing allowed or denied actions on specific resources

**What is S3?**
Simple Storage Service. AWS's object storage. Think: a hard drive in the cloud.
You store files (called "objects") in containers (called "buckets").
A bucket has a globally unique name. Objects are accessed by their "key" (filename + path).

**What is DynamoDB?**
AWS's managed NoSQL database. It stores data as items with attributes (like a spreadsheet).
We use it ONLY for Terraform state locking — one row per locked state file.

**What is the AWS CLI?**
A command-line tool that lets you interact with AWS from your terminal.
Examples:
```bash
aws s3 ls                    # List all your S3 buckets
aws iam list-users           # List all IAM users
aws ec2 describe-instances   # List all EC2 servers
```

### Tier 3 — Will Be Taught During the Build

The following concepts will be explained in detail as we encounter them:
- Terraform HCL syntax (what the code looks like and why)
- Terraform providers (what they are and where they come from)
- Terraform state file (what is inside it)
- Terraform modules (input/output/local values in detail)
- Terraform workspaces (and why we do NOT use them for environments)
- GitHub Actions YAML syntax (every keyword explained)
- Checkov and security scanning (how it works, what it checks)
- OPA/Conftest and policy-as-code (what it is and how to write policies)
- tflint and linting (what it catches that validate doesn't)
- pre-commit hooks (what they are and how they save time)

---

# PART VI — AWS SERVICES DEEP DIVE

## 6. Every Service We Use — Explained Completely

---

### Service 1: Amazon S3 (Remote State Storage)

**What is it?**
S3 stands for Simple Storage Service. It stores files (called "objects") in containers
(called "buckets"). Think of a bucket as a folder in the cloud, except it's globally
accessible, extremely durable, and has fine-grained access control.

**Why does AWS provide it?**
Because local disks fail. S3 stores data across multiple physical devices and multiple
facilities automatically. AWS guarantees 99.999999999% (eleven 9s) durability — if you
store 10 million files in S3, you would expect to lose one file every 10,000 years.

**What problem does it solve for us?**
Terraform's state file tracks everything Terraform has created in AWS.
Without a state file, Terraform cannot know what already exists.

By storing the state file in S3 instead of locally:
- Any computer can run Terraform (your laptop, CI/CD server, colleague's laptop)
- The state is backed up (S3 versioning keeps old versions)
- The state is encrypted (KMS encryption at rest)
- Access is audited (S3 access logs + CloudTrail)
- It cannot be lost when your laptop is stolen or reformatted

**When should I NOT use S3 for state?**
- Very small personal projects where local state is acceptable (only you, only one machine)
- When using Terraform Cloud — it provides built-in remote state management

**What does it cost?**
- Storage: $0.023 per GB per month (a 100 KB state file = $0.0000023/month ≈ free)
- Requests: $0.0004 per 1,000 requests (negligible at our scale)
- With 30 projects and hundreds of state files, total cost: < $0.01/month

**Security implications — CRITICAL:**
- The state file contains SECRETS IN PLAINTEXT (database passwords, private keys)
- The bucket MUST be private — never enable public access
- Encryption with KMS is mandatory (not optional)
- Access must be restricted to CI/CD role and administrators only
- Bucket policy must deny non-HTTPS requests
- S3 Object Lock can prevent deletion (consider for production)

**What happens if S3 is unavailable?**
Terraform cannot read or write state. All deployments stop.
S3 has a 99.99% availability SLA — the most reliable storage service on AWS.

**Exam connection (DOP-C02 / SAA-C03):**
S3 versioning, encryption, access control, and lifecycle policies are tested extensively.

---

### Service 2: Amazon DynamoDB (State Locking)

**What is it?**
DynamoDB is AWS's managed NoSQL database. "NoSQL" means it does not use tables with
fixed columns like a spreadsheet — instead, each item can have different attributes.
It stores data as key-value pairs and delivers single-digit millisecond read/write latency.

**Why does AWS provide it?**
For applications needing extremely fast, consistent, scalable data storage.
It scales from one request per second to millions automatically, with no server management.

**What problem does it solve for us?**
Terraform uses DynamoDB to implement a distributed lock — a flag that says
"I am running right now, everyone else must wait."

**What happens without locking (the horror story):**
```
09:00:00 — Engineer A starts terraform apply. Reads state: "VPC exists, subnet does not"
09:00:01 — Engineer B starts terraform apply. Also reads state: "VPC exists, subnet does not"
09:00:05 — Engineer A creates subnet-1a. Writes state: "VPC exists, subnet-1a exists"
09:00:06 — Engineer B creates subnet-1b. Writes state: "VPC exists, subnet-1b exists"
           ↑ Engineer B's write OVERWRITES Engineer A's write
09:00:07 — State now says "subnet-1b exists" but NOT "subnet-1a exists"
           ↑ Terraform thinks subnet-1a doesn't exist — might try to create it again
           ↑ Or worse: Terraform thinks subnet-1a is unmanaged and deletes it
RESULT: State corruption. Unknown infrastructure state. Potential data loss.
```

**With DynamoDB locking:**
```
09:00:00 — Engineer A starts terraform apply. Creates DynamoDB lock: "LOCKED by A"
09:00:01 — Engineer B starts terraform apply. Sees lock → ERROR: "State locked by A"
09:00:05 — Engineer A finishes. Lock released.
09:00:06 — Engineer B tries again. No lock. Proceeds safely.
RESULT: Sequential, safe, auditable.
```

**What does it cost?**
DynamoDB on-demand mode: $0.00 when idle, $0.00000125 per read, $0.00000625 per write.
Each Terraform run = ~5 reads + 5 writes = $0.000038 per run.
1,000 Terraform runs per month = $0.038. Essentially zero.

**What happens if DynamoDB fails?**
Terraform refuses to run — it cannot acquire the lock. This is the SAFE failure mode.
No state corruption occurs. Terraform waits until DynamoDB is available.
DynamoDB has a 99.999% availability SLA — more reliable than almost anything.

**Exam connection (DOP-C02):**
DynamoDB for state locking is a standard DevOps pattern tested on the exam.

---

### Service 3: AWS KMS (Key Management Service)

**What is it?**
KMS manages cryptographic keys — secret numbers used to encrypt and decrypt data.
Encryption means scrambling data so only someone with the correct key can read it.

**The simple explanation:**
Imagine you have a message: "DB password is hunter2"
Encryption scrambles it to: "xK9mLp2QrR7nWvYzA1bCdE"
Only someone with the encryption key can unscramble it back to the original.

**What problem does it solve for us?**
Our Terraform state file contains secrets in plaintext:
- Database passwords
- API keys
- Private IP addresses
- Account numbers and resource IDs

Without encryption, anyone who can access the S3 bucket can read ALL of this.
With KMS encryption, the data is scrambled and only IAM principals with explicit
permission to use the KMS key can decrypt it.

**Customer-managed key vs AWS-managed key:**
- AWS-managed key: AWS handles the key, you can't control rotation or audit details. Free.
- Customer-managed key (CMK): YOU own the key. $1/month. Full audit trail. Rotation control.
We use a CMK because the $1/month is worth the additional security posture and audit capability.

**What happens if the KMS key is deleted?**
Any data encrypted with that key becomes permanently unreadable.
This means your Terraform state is gone forever if you delete the KMS key.
KMS requires a 7-30 day waiting period before deletion for exactly this reason.
NEVER delete the KMS key used for state encryption.

**Cost:** $1.00/month flat per CMK + $0.03 per 10,000 API calls.

---

### Service 4: AWS IAM (CI/CD Identity)

**What is it?**
IAM (Identity and Access Management) controls who can do what in AWS.
Every API call to AWS must include credentials identifying the caller,
and IAM determines whether that caller is permitted to make that call.

**Key concept — OIDC (OpenID Connect):**

**The OLD way (bad):**
1. Create an IAM user for GitHub Actions
2. Generate an access key (a permanent credential)
3. Store the access key in GitHub Secrets
4. GitHub Actions uses the key to call AWS

**Why it's bad:**
- The access key is a permanent credential — valid forever until manually deleted
- If the key leaks (via logs, error messages, compromised laptop), the attacker has
  permanent AWS access until you manually rotate the key
- Hard to audit: the access key looks the same whether it's your CI/CD or an attacker

**The NEW way (OIDC — what we use):**
1. GitHub Actions generates a short-lived JWT (JSON Web Token) — a digital ID card
2. GitHub Actions sends the JWT to AWS
3. AWS verifies the JWT signature against GitHub's public key
4. AWS issues a temporary credential (expires in 1 hour)
5. GitHub Actions uses the temporary credential to call AWS

**Why it's better:**
- No stored long-lived credential anywhere
- Temporary credentials expire automatically
- Even if stolen, the credential is useless within an hour
- Audit trail shows exactly which GitHub repository and workflow made each call

**Cost:** IAM is free. OIDC is free.

---

# PART VII — ARCHITECTURE DESIGN

## 7. The Architecture (Four Levels of Detail)

### Level 1 — Business Architecture

```
Developer writes infrastructure code
         |
         v
Peer review (Pull Request)
         |
         v
Automated validation (CI pipeline)
         |
         v
Infrastructure deployed to AWS
         |
         v
Evidence captured + documented
```

### Level 2 — Logical Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Developer Workflow                          │
│                                                                 │
│  Write Terraform → Commit → Push → Open PR → Review → Merge    │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               v
┌─────────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline (GitHub Actions)              │
│                                                                 │
│  On PR:    fmt → validate → tflint → checkov → OPA → plan      │
│  On merge: manual approval → apply → notify                     │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               v
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Account                             │
│                                                                 │
│  ┌─────────────────┐    ┌────────────────────────────────────┐  │
│  │  State Backend  │    │        Deployed Infrastructure     │  │
│  │                 │    │                                    │  │
│  │  S3 bucket      │    │  VPC / IAM / EC2 / RDS / ECS /    │  │
│  │  DynamoDB table │    │  EKS / CloudFront / Monitoring     │  │
│  │  KMS key        │    │  (created by other projects)       │  │
│  └─────────────────┘    └────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Level 3 — Module Architecture

```
terraform/
│
├── bootstrap/
│   ├── main.tf          ← Creates S3 bucket, DynamoDB table, KMS key
│   ├── variables.tf     ← Input: company name, account ID, region
│   └── outputs.tf       ← Output: bucket name, table name, KMS ARN
│
├── modules/             ← THE MODULE LIBRARY (reusable building blocks)
│   │
│   ├── vpc/             ← Network foundation
│   │   ├── main.tf      ← VPC, subnets, IGW, NAT, route tables, flow logs
│   │   ├── variables.tf ← Input: CIDR, AZs, NAT count, tags
│   │   └── outputs.tf   ← Output: VPC ID, subnet IDs, security group IDs
│   │
│   ├── iam/             ← Identity and access
│   │   ├── main.tf      ← Roles, policies, OIDC provider, instance profiles
│   │   ├── variables.tf ← Input: role name, policies, trusted services
│   │   └── outputs.tf   ← Output: role ARNs, policy ARNs
│   │
│   ├── ec2/             ← Compute instances
│   │   ├── main.tf      ← Instance, security group, EBS, SSM, CloudWatch agent
│   │   ├── variables.tf ← Input: instance type, AMI, subnet, SG rules
│   │   └── outputs.tf   ← Output: instance ID, private IP, security group ID
│   │
│   ├── rds/             ← Managed relational database
│   │   ├── main.tf      ← Instance/cluster, subnet group, parameter group, SG
│   │   ├── variables.tf ← Input: engine, class, multi-AZ, storage, backup
│   │   └── outputs.tf   ← Output: endpoint, port, security group ID
│   │
│   ├── ecs/             ← Container platform
│   │   ├── main.tf      ← Cluster, service, task definition, ALB, auto scaling
│   │   ├── variables.tf ← Input: image, CPU, memory, desired count, port
│   │   └── outputs.tf   ← Output: cluster ARN, service name, ALB DNS
│   │
│   ├── eks/             ← Kubernetes platform
│   │   ├── main.tf      ← Cluster, node group, add-ons, IRSA, OIDC
│   │   ├── variables.tf ← Input: version, node type, node count, add-ons
│   │   └── outputs.tf   ← Output: cluster endpoint, kubeconfig, OIDC ARN
│   │
│   ├── cloudfront/      ← Content delivery network
│   │   ├── main.tf      ← Distribution, origins, behaviors, WAF, OAC, logging
│   │   ├── variables.tf ← Input: origin, certificate, behaviors, price class
│   │   └── outputs.tf   ← Output: domain name, distribution ID, hosted zone
│   │
│   └── monitoring/      ← Observability
│       ├── main.tf      ← Dashboard, alarms, SNS, log groups, metric filters
│       ├── variables.tf ← Input: alarm thresholds, email, dashboard name
│       └── outputs.tf   ← Output: dashboard URL, SNS topic ARN, alarm names
│
└── environments/
    ├── dev/             ← Small, cheap. Single AZ. For development.
    │   ├── main.tf      ← Calls modules with dev-sized values
    │   ├── backend.tf   ← Points to S3 state bucket, dev/ prefix
    │   ├── variables.tf ← Declares variables used in this environment
    │   └── terraform.tfvars ← Sets actual values for dev
    │
    ├── staging/         ← Medium. Multi-AZ. Pre-production testing.
    │   └── ...
    │
    └── production/      ← Full size. Multi-AZ. Maximum redundancy.
        └── ...
```

### Level 4 — Security Architecture

```
GitHub Actions Workflow
     │
     │ Step 1: Request OIDC token from GitHub
     │ Step 2: Send token to AWS STS
     │
     v
aws-actions/configure-aws-credentials
     │
     │ Validates token signature against:
     │ IAM OIDC Provider: token.actions.githubusercontent.com
     │
     v
AWS IAM Role: github-actions-terraform
     │
     │ Conditions (MUST all be true):
     │ - Token issuer = token.actions.githubusercontent.com
     │ - Audience = sts.amazonaws.com
     │ - Subject = repo:YOUR-ORG/YOUR-REPO:ref:refs/heads/main
     │
     │ Permissions granted:
     ├── S3: GetObject, PutObject, DeleteObject (state bucket only)
     ├── DynamoDB: GetItem, PutItem, DeleteItem (lock table only)
     ├── KMS: GenerateDataKey, Decrypt (state key only)
     └── [Additional per-module permissions added here]
     │
     v
Terraform runs with temporary credentials
(expire in 1 hour regardless of what happens)
```

---

# PART VIII — ARCHITECTURE DECISION RECORDS

## 8. Why Did We Design It This Way?

### ADR-001: Terraform over CloudFormation

**Status:** Accepted

**Context:** We need an IaC tool to define all 30 portfolio projects.

**Decision:** Use Terraform as the primary IaC tool.

**Alternatives considered:**

| Option | Pros | Cons |
|--------|------|------|
| Terraform | Multi-cloud, large ecosystem, readable HCL, industry standard | State management complexity, not native AWS |
| CloudFormation | Native AWS, no state file, deep AWS integration | AWS-only, verbose YAML, slower deployments |
| AWS CDK | Write IaC in real programming languages | Abstraction layer, generates CloudFormation (slower), steeper learning curve |
| Pulumi | Real programming languages, multi-cloud | Smaller community, less documentation |

**Why Terraform wins for this portfolio:**
- Most job postings list Terraform (employer expectation)
- Multi-cloud capability (future-proof)
- Terraform Registry has thousands of ready modules to learn from
- HCL is readable and easier to review than CDK-generated CloudFormation

**Trade-offs acknowledged:**
- State file is a liability CloudFormation does not have
- We mitigate this with remote state + locking + versioning
- CloudFormation knowledge still gained through certification study

---

### ADR-002: S3 + DynamoDB over Terraform Cloud

**Status:** Accepted

**Decision:** Use S3 + DynamoDB for remote state, not Terraform Cloud.

**Why:**
- $0/month vs Terraform Cloud's paid tiers for > 500 resources
- No external SaaS dependency (everything in your AWS account)
- Forces you to understand remote state mechanics (better learning)
- Full control over encryption, access, and audit

**Trade-offs:**
- Terraform Cloud provides a UI for plans and state (we use PR comments instead)
- Terraform Cloud handles sentinel policies natively (we use OPA/Conftest instead)

---

### ADR-003: Separate Environment Directories over Terraform Workspaces

**Status:** Accepted

**Decision:** Use `environments/dev/`, `environments/staging/`, `environments/production/`
as separate Terraform root modules. Do NOT use `terraform workspace`.

**Why NOT workspaces:**
Workspaces share the same code. A syntax error in your VPC code affects all workspaces
simultaneously. If you accidentally `terraform destroy` in workspace "staging" with
production-sized resources, you can destroy staging infrastructure while in the wrong workspace.

Separate directories are completely isolated. A `terraform apply` in `environments/dev/`
cannot touch `environments/production/` state. You must physically navigate to the
production directory and explicitly target it.

**Why directories work:**
```
environments/dev/terraform.tfvars   → small instances, single AZ
environments/staging/terraform.tfvars → medium instances, multi-AZ
environments/production/terraform.tfvars → large instances, multi-AZ, full HA
```
Same modules, different variable values. Same pattern, different sizes.

---

### ADR-004: Checkov + OPA/Conftest over a Single Tool

**Status:** Accepted

**Decision:** Use both Checkov (security scanning) AND OPA/Conftest (policy enforcement).

**Why two tools:**
- **Checkov** scans for known security misconfigurations (public S3, unencrypted RDS, open security groups)
  It uses a library of pre-built checks maintained by the Bridgecrew/Prisma team.
  You do not write the checks — they come pre-built.

- **OPA/Conftest** enforces YOUR custom business policies (required tags, approved instance types,
  maximum instance sizes, naming conventions). You write these policies in Rego language.
  It checks rules specific to YOUR organization that Checkov doesn't know about.

Together: Checkov = "Are you following security best practices?"
          OPA     = "Are you following OUR specific rules?"

---

# PART IX — BLIND-SPOT ANALYSIS

## 9. What Beginners Miss That Senior Engineers Catch

### Architecture Blind Spots

**Blind Spot: Storing Terraform state locally**
Why beginners miss it: Terraform works perfectly fine locally on one machine.
Why it matters: State is lost when the laptop dies. Two engineers corrupt state simultaneously.
How to detect: Check `terraform {backend ...}` block in main.tf — if absent, state is local.
How to fix: Configure S3 backend in bootstrap (what we build in Phase 1).

**Blind Spot: Checking `terraform.tfstate` into Git**
Why beginners miss it: "It's just another file, right?"
Why it matters: State files contain secrets IN PLAINTEXT. Database passwords. API keys.
Committed to Git = permanently exposed in history even after deletion.
How to detect: `git log --all -- "*.tfstate"` (should return nothing)
How to fix: Ensure `*.tfstate` and `*.tfstate.backup` are in `.gitignore` from Day 1.

**Blind Spot: Using Terraform workspaces for environment separation**
Why beginners miss it: The Terraform documentation mentions workspaces for this purpose.
Why it matters: Workspaces share state backend configuration. Errors in one can affect all.
The community consensus has moved to separate directories.
How to detect: `terraform workspace list` — if you see dev/staging/prod, this is the pattern.
How to fix: Use environments/ directory structure (what we build in Phase 10).

**Blind Spot: Hardcoding region and account ID in modules**
Why beginners miss it: It works. Right now.
Why it matters: The module cannot be reused in another region or account.
How to detect: `grep -r "ca-central-1" terraform/modules/` — should return nothing.
How to fix: Use `data "aws_region" "current" {}` and `data "aws_caller_identity" "current" {}`.

### Security Blind Spots

**Blind Spot: Using AWS access keys in GitHub Secrets**
Why beginners miss it: Many official tutorials still show this approach.
Why it matters: Long-lived credentials. If leaked → permanent AWS access until manually rotated.
How to detect: Check GitHub repository Settings → Secrets for AWS_ACCESS_KEY_ID.
How to fix: Delete the access key. Use OIDC (what we implement in modules/iam/).

**Blind Spot: Admin permissions for the CI/CD role**
Why beginners miss it: "It's easier — I know it has enough permissions."
Why it matters: Compromised CI/CD = admin access to your entire AWS account.
How to detect: `aws iam list-attached-role-policies --role-name [role]` — check for AdministratorAccess.
How to fix: Least privilege. Only the exact permissions Terraform needs.

**Blind Spot: Unencrypted S3 state bucket**
Why beginners miss it: S3 applies default encryption since January 2023. They assume it's set.
Why it matters: Default encryption uses AWS-managed keys — less audit visibility, less control.
How to detect: `aws s3api get-bucket-encryption --bucket [bucket]` — check for KMS key ARN.
How to fix: Explicitly configure KMS CMK encryption (done in bootstrap/main.tf).

### Operations Blind Spots

**Blind Spot: No S3 versioning on the state bucket**
Why beginners miss it: State appears to work without versioning.
Why it matters: State corruption or accidental deletion = permanent loss of infrastructure tracking.
Without versioning: corrupted state = hours of manual resource reconciliation.
How to detect: `aws s3api get-bucket-versioning --bucket [bucket]` — should show "Enabled".
How to fix: Enable versioning (done in bootstrap/main.tf).

**Blind Spot: No lifecycle policy on state bucket**
Why beginners miss it: Individual state files are tiny.
Why it matters: 30 projects × 200 applies each = 6,000 state file versions over time.
At scale: hundreds of old state versions consuming space unnecessarily.
How to detect: `aws s3api get-bucket-lifecycle-configuration --bucket [bucket]`.
How to fix: Add lifecycle rule to expire old state versions after 90 days (done in bootstrap).

**Blind Spot: Running terraform apply locally in production**
Why beginners miss it: It's faster than waiting for CI/CD.
Why it matters: No audit trail. No peer review. No approval gate. No rollback tracking.
How to detect: CloudTrail — look for S3 PutObject on state files from non-CI/CD principals.
How to fix: Remove local production credentials from engineer laptops entirely.

### Cost Blind Spots

**Blind Spot: NAT Gateway cost**
Why beginners miss it: NAT Gateways are created by the VPC module and feel like background infrastructure.
Why it matters: NAT Gateway = $0.045/hour + $0.045/GB data.
One NAT Gateway = ~$32/month just to exist.
Three NAT Gateways (Multi-AZ) = ~$96/month just for HA.
How to detect: `aws ec2 describe-nat-gateways --filter Name=state,Values=available`
How to fix: Use 1 NAT for dev/staging. Use 3 for production only. Destroy when not in use.

---

# PART X — THREAT MODEL

## 10. Security Before Deployment

| Threat | Likelihood | Impact | Control | Detection |
|--------|------------|--------|---------|-----------|
| State file read (secrets leak) | Medium | Critical | S3 private + KMS + least-privilege | CloudTrail S3 access logs |
| State file corruption | Low | Critical | DynamoDB locking + S3 versioning | Versioning history + monitoring |
| Compromised CI/CD credentials | Medium | Critical | OIDC (no long-lived keys) | CloudTrail AssumeRoleWithWebIdentity |
| Unauthorized terraform apply | Medium | High | IAM + manual approval gate | CloudTrail + GitHub audit log |
| Malicious Terraform module | Low | Critical | Module pinning + Checkov scan | Code review + scanning |
| Privilege escalation via IAM | Medium | Critical | OPA policy blocks `*` permissions | Conftest in CI/CD |
| Accidental `terraform destroy` | Medium | Critical | Manual approval gate + plan review | GitHub Actions approval log |
| State bucket public exposure | Low | Critical | S3 Block Public Access enabled | AWS Config rule |
| KMS key deletion | Very Low | Critical | KMS deletion protection (30-day wait) | CloudTrail KMS events |
| Secret values in .tf files | High | High | .gitignore + GitHub secret scanning | Pre-commit hook + scanning |

### Recovery Procedures

**If state is corrupted:**
```
1. STOP all Terraform operations immediately (announce to team)
2. Open S3 versioning history: aws s3api list-object-versions --bucket [bucket] --prefix [key]
3. Identify the last known-good state (by timestamp — just before the corruption event)
4. Restore: aws s3api copy-object --bucket [b] --copy-source [b]/[k]?versionId=[id] --key [k]
5. Run terraform plan — verify it shows expected changes (should show none)
6. Resume operations. Document the incident.
```

**If CI/CD role is compromised:**
```
1. Immediately deny all: aws iam put-role-policy --role-name [role] --policy-name EMERGENCY-DENY
   with policy: {"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"*","Resource":"*"}]}
2. Audit CloudTrail for all API calls from this role in last 24 hours
3. Identify and remediate any unauthorized changes
4. Recreate the IAM role with a new name
5. Update GitHub OIDC configuration to use new role ARN
6. Document in incident log
```

---

# PART XI — COST MODEL

## 11. What This Platform Costs

### Monthly Cost Estimate

| Service | Resource | Quantity | Unit Cost | Monthly |
|---------|----------|----------|-----------|---------|
| S3 | State storage (~10 MB) | 10 MB | $0.023/GB | $0.00 |
| S3 | Versioned objects (~50 MB) | 50 MB | $0.023/GB | $0.00 |
| S3 | Requests (~1,000/month) | 1,000 | $0.0004/1000 | $0.00 |
| DynamoDB | Lock table (on-demand) | 500 R/W | Per request | $0.01 |
| KMS | Customer-managed key | 1 key | $1.00/month | $1.00 |
| KMS | API calls (~500/month) | 500 | $0.03/10,000 | $0.00 |
| **TOTAL** | | | | **~$1.01/month** |

### The Only Real Cost: The KMS Key
$1.00/month is the flat fee for a customer-managed KMS key, regardless of usage.
This is the right trade-off: $12/year for full encryption control, key rotation, and audit.

### What Would Increase Cost
- Enabling S3 Intelligent-Tiering (unnecessary — state files are accessed frequently)
- Running thousands of Terraform applies per day (KMS API costs, still negligible)
- Storing large state files (only a concern for very large infrastructure — thousands of resources)

### Comparison

| Approach | Monthly Cost | Features |
|----------|-------------|---------|
| Local state (no backend) | $0 | No team collaboration. No audit. No backup. |
| S3 + DynamoDB (this project) | ~$1/month | Full remote state, locking, encryption, versioning |
| Terraform Cloud (free tier) | $0 (limited) | 500 managed resources max, then paid |
| Terraform Cloud (paid) | $20+/month | Unlimited, UI, Sentinel policies |

**Our choice ($1/month) is the best value for learning and a portfolio.**

---

# PART XII — IMPLEMENTATION PLAN

## 12. Build Plan

### Phase 0 — Environment Setup (Day 1)
- Task 0.1: Install all required tools
- Task 0.2: Verify all tools work
- Task 0.3: Configure AWS CLI
- Task 0.4: Create GitHub repository
- Task 0.5: Configure Git locally

### Phase 1 — Bootstrap (Day 1–2) ← DEPLOY THIS NOW
- Task 1.1: Understand what bootstrap creates
- Task 1.2: Review bootstrap Terraform code (understand every line)
- Task 1.3: Run terraform init
- Task 1.4: Run terraform plan (read every line of the plan)
- Task 1.5: Run terraform apply
- Task 1.6: Migrate local state to S3 remote state
- Task 1.7: Verify all resources in AWS Console
- Task 1.8: Capture evidence screenshots

### Phase 2 — Module: VPC (Day 3–5)
- Task 2.1: Understand what a VPC is (concepts first)
- Task 2.2: Design the VPC CIDR and subnet layout
- Task 2.3: Review and understand modules/vpc/main.tf
- Task 2.4: Test the module in dev environment
- Task 2.5: Verify all networking components
- Task 2.6: Destroy dev VPC after testing

### Phase 3 — Module: IAM (Day 5–7)
- Task 3.1: Understand IAM roles, policies, and trust relationships
- Task 3.2: Review modules/iam/main.tf
- Task 3.3: Deploy and test the IAM module
- Task 3.4: Verify least-privilege permissions

### Phase 4–9 — Remaining Modules (Day 7–13)
- EC2, RDS, ECS, EKS, CloudFront, Monitoring modules
- Same pattern: understand → review → deploy → verify → destroy

### Phase 10 — Environments (Day 13–14)
- Wire together all modules in dev, staging, production configurations
- Set environment-appropriate variable values

### Phase 11 — CI/CD Pipeline (Day 14–16)
- Implement GitHub Actions workflows
- Test the complete PR → plan → approve → apply flow

### Phase 12 — Security & Policy (Day 16–17)
- Configure Checkov to pass on all modules
- Write OPA policies and configure Conftest
- Configure pre-commit hooks

### Phase 13 — Testing (Day 17–18)
- Happy path testing (everything works)
- Failure testing (state lock, state corruption, policy violation)

### Phase 14–15 — Documentation & Portfolio (Day 18–21)
- Complete ADRs, runbooks, cost analysis
- Write README for GitHub
- Capture all evidence

---

# PART XIII — STEP-BY-STEP BUILD (Phases 0 and 1 Detailed)

## 13. Phase 0: Environment Setup — Every Step Explained

### Task 0.4 — Create and Configure Git Repository

**Objective:** Create the GitHub repository that will hold all your infrastructure code.

**Why before anything else?**
Everything we build will be committed to Git from the start. Building without Git
means retrofitting it later — adding Git after the fact is harder and creates messy history.

**Step 1:** Create a repository on GitHub
1. Go to github.com and sign in
2. Click the + icon in the top right
3. Click "New repository"
4. Fill in:
   - Repository name: `aws-portfolio-infrastructure`
   - Description: `Enterprise IaC platform for 30-project AWS portfolio`
   - Visibility: Public (so your portfolio is visible to employers)
   - Initialize with README: Yes
5. Click "Create repository"

**Step 2:** Clone the repository to your computer
```bash
git clone https://github.com/YOUR-USERNAME/aws-portfolio-infrastructure.git
cd aws-portfolio-infrastructure
```

**What `git clone` does:**
- Downloads the entire repository from GitHub to your computer
- Creates a folder with the same name as the repository
- Automatically configures Git so `git push` knows where to send changes

**What `cd` does:** "Change Directory." Moves your terminal into the project folder.

**Step 3:** Create the folder structure
```bash
mkdir -p terraform/{bootstrap,modules/{vpc,iam,ec2,rds,ecs,eks,cloudfront,monitoring},environments/{dev,staging,production}}
mkdir -p .github/workflows architecture/{adr,diagrams} docs runbooks evidence policies/opa
```

**What `mkdir -p` does:**
- `mkdir` = make directory
- `-p` = create parent directories too (so `mkdir -p a/b/c` creates a, then b inside a, then c inside b)
- The `{...}` syntax expands into multiple directories at once (shell brace expansion)

**Step 4:** Create the .gitignore file
```bash
cat > .gitignore << 'EOF'
# Terraform state files — NEVER commit these. They contain secrets.
*.tfstate
*.tfstate.backup
*.tfstate.*.backup

# Terraform directory (downloaded plugins — large and machine-specific)
.terraform/

# Terraform plan files (binary files, not human-readable in Git)
*.tfplan

# Variable files that may contain secrets
*.tfvars.local
*.auto.tfvars

# Crash logs
crash.log
crash.*.log

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Lock file is kept in Git (tracks provider versions for reproducibility)
# .terraform.lock.hcl  ← do NOT gitignore this one

# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/settings.json
*.swp
*.swo
EOF
```

**Why each entry matters:**
- `*.tfstate` — Contains secrets in plaintext. NEVER in Git.
- `.terraform/` — Provider plugins. 100MB+. Machine-specific. Downloads automatically.
- `*.tfplan` — Binary file. Generated fresh on each run. No need in Git.
- `.terraform.lock.hcl` — NOT gitignored. This file records exact provider versions.
  It ensures your colleagues use the same provider version you do.

**Step 5:** Make your first commit
```bash
git add .gitignore
git commit -m "chore: add terraform gitignore"
git push origin main
```

**What each command does:**
- `git add .gitignore` — Stage the file (mark it to be included in the next commit)
- `git commit -m "..."` — Create a snapshot with the message describing the change
- `git push origin main` — Upload the commit to GitHub (origin = GitHub, main = branch name)

> **STOP AND VERIFY:**
> 1. Go to your GitHub repository in your browser
> 2. You should see the `.gitignore` file in the repository
> 3. The commit message should appear in the commit history
>
> **If you see an error when pushing:** You may need to set up SSH keys or use a personal
> access token. Ask the AI to walk you through GitHub authentication setup.

---

---

## 13b. Phase 1: Bootstrap — Every Step Explained

> This section gives you the deep "why" behind the bootstrap steps.
> The "what to type" is in DIRECTOR.md → Phase 1. Read this section FIRST
> to understand what you're running — then execute in DIRECTOR.md.

### What Is the Bootstrap Problem?

Terraform needs somewhere to store its state file. The best place is S3.
But to create the S3 bucket, you need Terraform to run.
That's circular: Terraform needs S3, S3 needs Terraform.

**The solution:** Run Terraform once with LOCAL state to create the S3 bucket.
Then migrate that local state file into the S3 bucket you just created.
From that point forward, all state (including the bootstrap module's own state) lives in S3.

This is called the bootstrap paradox and every Terraform project at scale faces it.

```
STEP 1: Run terraform apply using local state
         ↓
STEP 2: S3 bucket, DynamoDB table, KMS key are created in AWS
         ↓
STEP 3: Uncomment backend.tf to point at the new S3 bucket
         ↓
STEP 4: Run terraform init -migrate-state
         ↓
STEP 5: Terraform copies the local state file into S3
         ↓
RESULT: Bootstrap module's state now lives in the bucket it created
```

### Task 1.1 — Review the Bootstrap Files Before Running Anything

Before you run a single command, open each file and read it.
This is Rule 3 of the Operating Contract: you understand what you're deploying.

**terraform/bootstrap/main.tf** creates:

| Resource | Type | Why |
|----------|------|-----|
| `aws_kms_key` | KMS Customer Managed Key | Encrypts everything in the state bucket |
| `aws_kms_alias` | KMS Alias | Human-readable name for the key |
| `aws_s3_bucket` | S3 Bucket | Stores all Terraform state files |
| `aws_s3_bucket_versioning` | S3 Versioning | Keeps every version of every state file |
| `aws_s3_bucket_server_side_encryption_configuration` | S3 Encryption | Forces KMS encryption on every object |
| `aws_s3_bucket_public_access_block` | S3 Public Block | Makes it impossible to accidentally expose state |
| `aws_s3_bucket_lifecycle_configuration` | S3 Lifecycle | Moves old versions to cheaper storage after 90 days |
| `aws_dynamodb_table` | DynamoDB Table | State locking — prevents two terraform applies at once |

**Why 9 resources from one "state bucket"?**
Because a production-grade S3 bucket is not just a bucket. It needs:
encryption (KMS), versioning, public access blocked, lifecycle policy.
Each of those is a separate AWS resource that Terraform manages individually.

**terraform/bootstrap/backend.tf** starts commented out.
After the first apply succeeds, you uncomment it and run `terraform init -migrate-state`.
Opening this file reveals the backend configuration that will be activated in Step 1.4.

**terraform/bootstrap/terraform.tfvars** is where you put YOUR values.
Every placeholder (`YOUR-NAME-HERE`, `YOUR-12-DIGIT-ID`) must be replaced before running.

### Task 1.2 — Edit terraform.tfvars

Open `terraform/bootstrap/terraform.tfvars` and replace all placeholder values:

```hcl
company_name   = "rahmat"          # your name, lowercase, no spaces
aws_account_id = "362339781462"    # your 12-digit account ID
aws_region     = "ca-central-1"    # the region you're deploying to
```

**Why company_name matters:** It becomes part of every resource name and tag.
The S3 bucket will be named `terraform-state-362339781462-ca-central-1`.
The KMS alias will be `alias/rahmat-terraform-state`.
This naming makes it easy to find your resources and proves they're yours.

**Why you must NOT use spaces in company_name:**
AWS resource names don't allow spaces. Terraform will error if you put "Rahmat Hassan"
as the company_name. Use "rahmat" or "rahmat-hassan" (hyphens are fine).

### Task 1.3 — Run terraform init

```bash
cd terraform/bootstrap
terraform init
```

**What terraform init does:**
1. Reads the `required_providers` block in `versions.tf`
2. Downloads the AWS provider (a plugin that translates Terraform HCL into AWS API calls)
3. Downloads the `random` provider (used to generate unique suffixes)
4. Creates the `.terraform/` directory with the downloaded plugins
5. Creates (or verifies) `.terraform.lock.hcl` — the provider version lock file

**What "Terraform has been successfully initialized" means:**
All plugins downloaded, versions locked, backend configured. You're ready to plan.

**What to look for in the output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
- Installed hashicorp/aws v5.x.x
Terraform has been successfully initialized!
```

### Task 1.4 — Run terraform plan (Read Every Line)

```bash
terraform plan
```

**What terraform plan does:**
1. Reads your `.tf` files
2. Reads the current state (local, since backend isn't active yet)
3. Calls the AWS API to check what actually exists in your account
4. Compares what SHOULD exist (your .tf files) vs what DOES exist (AWS)
5. Outputs a list of changes it will make

**The plan output uses three symbols:**
- `+` = will be CREATED (green)
- `-` = will be DESTROYED (red)
- `~` = will be MODIFIED in place (yellow)

**What you should see:** 9 resources to add, 0 to change, 0 to destroy.

```
Plan: 9 to add, 0 to change, 0 to destroy.
```

If you see a different number, stop and investigate before applying.

**Why read the plan?**
Senior engineers read every line of the plan before applying.
Junior engineers just type `yes`. The plan is your last chance to catch a mistake before
Terraform makes real AWS API calls with real money implications.

### Task 1.5 — Run terraform apply

```bash
terraform apply
```

Terraform will show the plan again and ask for confirmation.
Type `yes` (not "y", not "YES", exactly `yes`) and press Enter.

**What happens during apply:**
Terraform creates resources in dependency order. It knows, for example, that the S3 bucket
must exist before it can enable versioning on it. The dependency graph is implicit in the
`resource` references in your `.tf` files — if `aws_s3_bucket_versioning` references
`aws_s3_bucket.state.id`, Terraform knows the bucket must be created first.

**Expected final output:**
```
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:
kms_key_arn       = "arn:aws:kms:ca-central-1:362339781462:key/..."
kms_key_id        = "alias/rahmat-terraform-state"
lock_table_name   = "terraform-locks"
state_bucket_arn  = "arn:aws:s3:::terraform-state-362339781462-ca-central-1"
state_bucket_name = "terraform-state-362339781462-ca-central-1"
```

**Copy the output values into a safe notepad.** You need them in the next step.

**Where is the state file right now?**
In `terraform/bootstrap/terraform.tfstate` — a local file on your computer.
It contains the resource IDs of everything Terraform just created.
This file must NOT be committed to Git (it's in your .gitignore).

### Task 1.6 — Verify Resources in AWS Console

Before migrating state, verify that all 9 resources actually exist in AWS.
This is Rule 5: verify before proceeding.

**S3 Bucket:**
1. AWS Console → S3
2. Find bucket named `terraform-state-YOUR_ACCOUNT_ID-ca-central-1`
3. Click the bucket → Properties tab
4. Verify: Bucket Versioning = Enabled
5. Verify: Default encryption = AWS-KMS with your key alias
6. Click Permissions tab
7. Verify: Block all public access = all four items ON

**DynamoDB Table:**
1. AWS Console → DynamoDB → Tables
2. Find `terraform-locks`
3. Verify: Table status = Active
4. Verify: Billing mode = PAY_PER_REQUEST (no fixed capacity charges)

**KMS Key:**
1. AWS Console → KMS → Customer managed keys
2. Find your key (search for your company_name)
3. Verify: Key status = Enabled
4. Verify: Key rotation = Enabled

> ⚠️ **NEVER DELETE THIS KMS KEY.**
> If you delete it, every state file encrypted with it becomes permanently unreadable.
> AWS does not let you "un-delete" a KMS key after the deletion waiting period.
> The key has a 30-day scheduled deletion period — if you accidentally schedule deletion,
> cancel it immediately in the AWS Console.

### Task 1.7 — Migrate State to S3

Open `terraform/bootstrap/backend.tf`.
Find the commented-out terraform backend block and uncomment it:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-YOUR_ACCOUNT_ID-ca-central-1"
    key            = "bootstrap/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    kms_key_id     = "alias/rahmat-terraform-state"
    dynamodb_table = "terraform-locks"
  }
}
```

Replace `YOUR_ACCOUNT_ID` with your actual account ID from Step 1.5.

Then run:
```bash
terraform init -migrate-state
```

**What -migrate-state does:**
1. Sees that the backend configuration changed (from local to S3)
2. Reads the local state file at `terraform/bootstrap/terraform.tfstate`
3. Asks: "Do you want to copy existing state to the new backend?"
4. When you type `yes`, it uploads the state file to S3
5. From this point, all terraform commands read/write state from S3

**Verify the migration worked:**
```bash
aws s3 ls s3://terraform-state-YOUR_ACCOUNT_ID-ca-central-1/bootstrap/
```

You should see `terraform.tfstate` listed in the S3 path.

**What happened to the local state file?**
It still exists at `terraform/bootstrap/terraform.tfstate` but Terraform no longer uses it.
The S3 version is now authoritative. The local file is now just a backup artifact.
You can delete it if you want, but it won't affect anything since Terraform uses S3.

### Task 1.8 — Final Confirmation

Run `terraform plan` one more time from the bootstrap directory:

```bash
terraform plan
```

Expected output:
```
No changes. Your infrastructure matches the configuration.
```

This confirms:
- State migration worked (Terraform can read from S3)
- State locking works (DynamoDB was used to lock during the plan)
- KMS encryption works (S3 returned the decrypted state file)

You are now ready for GATE 1 verification.

---

# PART XIV — VERIFICATION GATES

## 14. What "Done" Looks Like at Each Major Stage

```
GATE 0 — Environment Ready
  ✓ terraform version → v1.5.0 or higher
  ✓ aws --version → v2.x
  ✓ git --version → 2.x
  ✓ tflint --version → output returned
  ✓ checkov --version → output returned
  ✓ aws sts get-caller-identity → returns your Account ID
  ✓ GitHub repository created and cloned
  ✓ .gitignore committed

GATE 1 — Bootstrap Deployed
  ✓ S3 bucket visible: aws s3 ls | grep terraform-state
  ✓ S3 versioning enabled: aws s3api get-bucket-versioning --bucket [name]
  ✓ S3 encryption enabled: aws s3api get-bucket-encryption --bucket [name]
  ✓ S3 public access blocked: aws s3api get-public-access-block --bucket [name]
  ✓ DynamoDB table visible: aws dynamodb list-tables
  ✓ KMS key created: aws kms list-keys (count increased by 1)
  ✓ State file visible in S3: aws s3 ls s3://[bucket]/bootstrap/

GATE 2 — VPC Module Works
  ✓ terraform validate passes in environments/dev/
  ✓ tflint passes (0 errors)
  ✓ checkov passes (0 failed or all acknowledged)
  ✓ terraform plan shows expected VPC resources
  ✓ terraform apply succeeds
  ✓ VPC visible in console: aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev"
  ✓ Subnets visible in all AZs
  ✓ Internet Gateway attached
  ✓ NAT Gateway running
  ✓ terraform destroy succeeds (clean teardown)

GATE 3 — CI/CD Pipeline Works
  ✓ Push to feature branch triggers terraform-ci.yml
  ✓ All 5 checks pass (fmt, validate, tflint, checkov, OPA)
  ✓ terraform plan is generated and posted as PR comment
  ✓ Merge to main triggers terraform-apply.yml
  ✓ Manual approval gate appears and works
  ✓ terraform apply runs after approval
  ✓ Results posted back to PR

GATE 4 — Full Module Library Complete
  ✓ All 8 modules pass tflint and checkov with 0 errors
  ✓ All 8 modules have README.md with usage example
  ✓ All 8 modules have complete variables.tf with descriptions
  ✓ All 8 modules have complete outputs.tf

GATE 5 — Documentation Complete
  ✓ README.md complete with architecture diagram
  ✓ All 5 ADRs written
  ✓ Threat model complete
  ✓ Cost analysis complete
  ✓ Operations runbook complete
  ✓ All evidence screenshots captured
```

---

# PART XVII — GIT AND CI/CD

## 17. Git Workflow and Branch Strategy

### Branch Naming Convention

```
feature/[issue-number]-[short-description]
fix/[short-description]
docs/[short-description]
refactor/[short-description]
security/[short-description]
```

Examples:
```
feature/19-vpc-module-foundation
feature/19-iam-oidc-github-actions
fix/vpc-module-nat-gateway-count
docs/adr-002-remote-state-decision
security/restrict-ci-cd-role-permissions
```

### Commit Message Convention (Conventional Commits)

Format: `type(scope): description`

Types:
- `feat` — new feature or resource
- `fix` — bug fix
- `docs` — documentation only
- `refactor` — code restructure, no behavior change
- `security` — security improvement
- `cost` — cost optimization
- `ci` — CI/CD pipeline change
- `chore` — maintenance (gitignore, tooling)

Examples:
```
feat(vpc): add VPC flow logs to CloudWatch Logs
fix(rds): correct subnet group to use data subnets not app subnets
docs(adr): document decision to use S3 over Terraform Cloud
security(iam): enforce IMDSv2 on all EC2 instances
cost(vpc): make NAT gateway count configurable by environment
ci(actions): add checkov security scan to PR pipeline
```

### Full Pull Request Lifecycle

```
1. Create feature branch:
   git checkout -b feature/19-vpc-module

2. Write Terraform code in modules/vpc/

3. Test locally before committing:
   cd terraform/environments/dev
   terraform validate
   tflint
   checkov -d ../../modules/vpc

4. Commit with meaningful message:
   git add terraform/modules/vpc/
   git commit -m "feat(vpc): implement VPC module with public and private subnets"

5. Push to GitHub:
   git push origin feature/19-vpc-module

6. Open PR on GitHub:
   - Title: "feat(vpc): implement VPC module with public and private subnets"
   - Description: What changed, why, and how to test

7. GitHub Actions runs automatically:
   - terraform fmt check
   - terraform validate
   - tflint
   - checkov
   - OPA/Conftest policy check
   - terraform plan (posted as PR comment)

8. Review the terraform plan in the PR comment:
   - Does it show exactly what you expect?
   - Are there any unexpected changes?
   - Are there any deletions?

9. Request review from a peer (or self-review for this portfolio)

10. Merge to main after approval

11. GitHub Actions runs terraform apply:
    - Manual approval gate (click "Approve" in GitHub Actions)
    - terraform apply
    - Results posted back

12. Verify in AWS Console that changes are live

13. Update the PROJECT.md status tracker
```

---

# PART XXVI — WELL-ARCHITECTED REVIEW

## 26. Six-Pillar Review

Complete this table after finishing the project. Be honest — this review is for learning.

| Pillar | Score (1–5) | Key Issues Found | Improvements Made |
|--------|-------------|-----------------|-------------------|
| Operational Excellence | | | |
| Security | | | |
| Reliability | | | |
| Performance Efficiency | | | |
| Cost Optimization | | | |
| Sustainability | | | |

### Pillar 1: Operational Excellence
- [x] Infrastructure defined as code (Terraform)
- [x] Changes reviewed before deployment (pull requests)
- [x] Automated testing (CI pipeline: fmt, validate, lint, security)
- [x] Runbooks documented (state recovery, lock release, emergency apply)
- [x] Incident response procedure documented
- [ ] Automated drift detection (scheduled plan that alerts on differences)
- [ ] Deployment frequency and failure rate metrics

### Pillar 2: Security
- [x] State encrypted at rest (KMS CMK)
- [x] State not publicly accessible (S3 Block Public Access)
- [x] No long-lived CI/CD credentials (OIDC, temporary credentials)
- [x] Least-privilege IAM role for CI/CD
- [x] Security scanning on every PR (Checkov)
- [x] Policy-as-code enforcement (OPA/Conftest)
- [x] .gitignore prevents state files from being committed
- [ ] State bucket access logged to security SIEM
- [ ] Automated secret scanning in Git history

### Pillar 3: Reliability
- [x] State stored durably in S3 (11 nines)
- [x] State versioned (S3 versioning — can restore from any point)
- [x] State locking prevents concurrent corruption (DynamoDB)
- [x] Recovery procedure documented and tested
- [ ] Multi-region state replication (future — overkill for portfolio)
- [ ] Automated state backup verification

### Pillar 4: Performance Efficiency
- [x] On-demand DynamoDB (no over-provisioned capacity)
- [ ] CI/CD pipeline caching for Terraform providers (~30s saved per run)
- [ ] Parallel module testing in CI/CD

### Pillar 5: Cost Optimization
- [x] On-demand DynamoDB (pay exactly for what you use)
- [x] S3 lifecycle rules (automatically delete old state versions after 90 days)
- [x] Configurable NAT Gateway count (1 for dev, 3 for prod — saves ~$64/month per dev env)
- [ ] Cost allocation tags on all bootstrap resources

### Pillar 6: Sustainability
- [x] Modules enable resource reuse (no duplicate code = less cognitive load)
- [x] Destroy procedures documented (clean up unused resources)
- [x] Environment-appropriate sizing (dev uses minimal resources)
- [ ] AWS Carbon Footprint Tool integration

---

# PART XXIX — TEACH-BACK

## 29. Stop. Answer These Without Looking.

> **The rule:** Close this document. Answer in your own words.
> Open the document only after attempting each question.
> If you cannot answer, re-read the relevant section before moving forward.

### Level 1 — Basic Understanding (you must pass this before building)

1. What is Terraform? Explain it to someone who has never heard of it.
2. What is a Terraform state file? What information does it contain?
3. Why is it dangerous to store the state file on your laptop?
4. What is an S3 bucket? What is an object? What is a key?
5. What is DynamoDB? Why do we use it in this project?
6. Walk me through exactly what happens when two engineers run `terraform apply` simultaneously without locking.
7. What does `terraform init` do? What does it download?
8. What does `terraform plan` do? Does it change anything in AWS?
9. What does `terraform apply` do? Why do we use `-out=planfile` with plan first?
10. What is a Terraform module? Give an example of why you would use one.

### Level 2 — Technical Explanation (you must pass this before CI/CD phase)

1. Explain the difference between `variables.tf` and `terraform.tfvars`.
2. Explain `outputs.tf` and give a real example of when it is necessary.
3. Why do we use OIDC for GitHub Actions instead of AWS access keys?
4. What does "least privilege" mean? Give a specific example for our CI/CD role.
5. What is a KMS key? What does encryption actually do to the state file?
6. How does S3 versioning protect us? Walk through a recovery scenario.
7. What does `terraform fmt` do? Why run it in CI and not just locally?
8. What is Checkov? What kind of problems does it catch? Give three examples.
9. What is OPA/Conftest? How is it different from Checkov?
10. Explain the difference between `terraform plan` and `terraform apply`. Why have both?

### Level 3 — Senior Architecture Reasoning (for interview readiness)

1. Why did we choose separate environment directories instead of Terraform workspaces?
2. A junior engineer wants admin IAM permissions for the CI/CD role because "it's easier."
   What do you tell them? What specific risks do you cite?
3. The CTO asks: "Why are we using Terraform when AWS has CloudFormation?"
   Give a complete, professional answer.
4. You discover a developer committed a `terraform.tfvars` file with a database password to Git.
   What are your immediate steps? What are the long-term steps?
5. A senior engineer reviews your architecture and says "there's no drift detection."
   Explain what drift detection is, why it matters, and how you would implement it.

---

# PART XXX — INTERVIEW SIMULATION

## 30. Senior Engineer Interview

> Mode: INTERVIEWER. I have only read your GitHub README. I know nothing else.
> Answer as if this is a real job interview for a Senior Cloud/DevOps Engineer role.

**Q1:** "Walk me through this IaC platform. What does it do and why did you build it?"

**Q2:** "Why Terraform over CloudFormation? What are the trade-offs you considered?"

**Q3:** "You're using S3 and DynamoDB for remote state. Why not Terraform Cloud?"

**Q4:** "What happens if your S3 bucket is accidentally deleted? Walk me through recovery step by step."

**Q5:** "What is the biggest security risk in this architecture? How are you mitigating it?"

**Q6:** "I see GitHub Actions is your CI/CD. What happens if GitHub is down? Can your team still deploy?"

**Q7:** "How does your CI/CD pipeline authenticate to AWS? Explain the OIDC flow in detail."

**Q8:** "A developer bypasses your pipeline and runs `terraform apply` locally in production.
How do you detect this? How do you prevent it in the future?"

**Q9:** "How would this architecture change if the company grew from one AWS account to 50?"

**Q10:** "What would you add next to make this more production-ready? Give me your top 3 improvements."

**Grading:** Score each answer 1–5.
- 1: Could not answer
- 2: Vague answer, missing key details
- 3: Correct answer, basic level
- 4: Correct answer with trade-offs and alternatives
- 5: Complete answer with real-world context and senior judgment

---

# PART XXXII — EVIDENCE LIBRARY

## 32. Screenshot Evidence to Collect

Store all screenshots in the `evidence/` directory with descriptive names.

| Filename | What to Capture |
|----------|-----------------|
| `01-s3-state-bucket.png` | S3 console showing the state bucket with correct name |
| `02-s3-versioning-enabled.png` | S3 Properties tab showing versioning = Enabled |
| `03-s3-encryption-enabled.png` | S3 Properties tab showing encryption = AWS-KMS with your key |
| `04-s3-public-access-blocked.png` | S3 Permissions tab showing all Block Public Access = On |
| `05-dynamodb-lock-table.png` | DynamoDB console showing terraform-state-locks table |
| `06-kms-key.png` | KMS console showing the state encryption key |
| `07-state-file-in-s3.png` | S3 Objects view showing terraform.tfstate in the bucket |
| `08-state-file-versions.png` | S3 Versions tab showing multiple state versions |
| `09-iam-oidc-provider.png` | IAM console showing GitHub OIDC provider |
| `10-iam-ci-cd-role.png` | IAM role for GitHub Actions with least-privilege policy |
| `11-terraform-plan-output.png` | Terminal showing terraform plan with expected resources |
| `12-terraform-apply-success.png` | Terminal showing Apply complete! N added |
| `13-github-actions-ci-green.png` | GitHub PR showing all CI checks passing |
| `14-github-actions-plan-comment.png` | GitHub PR comment showing the terraform plan |
| `15-github-actions-apply-approval.png` | GitHub Actions showing the manual approval gate |
| `16-github-actions-apply-success.png` | GitHub Actions showing successful apply |
| `17-checkov-results.png` | Checkov output showing 0 failed checks |
| `18-state-lock-blocked.png` | Second terminal blocked by DynamoDB state lock |
| `19-state-recovery.png` | S3 version list and successful state restoration |
| `20-cloudtrail-evidence.png` | CloudTrail showing who ran Terraform and when |

---

# PROJECT STATUS TRACKER

Update this as you complete each section.

| # | Section | Status | Date | Notes |
|---|---------|--------|------|-------|
| 1 | Project Identity | [ ] | | |
| 2 | Business Scenario | [ ] | | |
| 3 | Requirements Analysis | [ ] | | |
| 4 | Learning Objectives | [ ] | | |
| 5 | Prerequisite Knowledge | [ ] | | |
| 6 | Service Learning | [ ] | | |
| 7 | Architecture Design | [ ] | | |
| 8 | ADRs | [ ] | | |
| 9 | Blind Spots | [ ] | | |
| 10 | Threat Model | [ ] | | |
| 11 | Cost Model | [ ] | | |
| 12 | Implementation Plan | [ ] | | |
| 13 | Step-by-Step Build | [ ] | | |
| 14 | Verification Gates | [ ] | | |
| 15 | Console + CLI + IaC | [ ] | | |
| 16 | Automation Backlog | [ ] | | |
| 17 | Git + CI/CD | [ ] | | |
| 18 | Functional Testing | [ ] | | |
| 19 | Failure Testing | [ ] | | |
| 20 | Observability | [ ] | | |
| 21 | Incident Response | [ ] | | |
| 22 | Disaster Recovery | [ ] | | |
| 23 | Performance Testing | [ ] | | |
| 24 | Security Validation | [ ] | | |
| 25 | Cost Optimization | [ ] | | |
| 26 | Well-Architected Review | [ ] | | |
| 27 | Architecture V2 | [ ] | | |
| 28 | Certification Mapping | [ ] | | |
| 29 | Teach-Back | [ ] | | |
| 30 | Interview Simulation | [ ] | | |
| 31 | Portfolio Documentation | [ ] | | |
| 32 | Evidence Library | [ ] | | |
