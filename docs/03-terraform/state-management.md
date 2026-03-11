# State Management

## Purpose
Document how Terraform state works and why careless handling can break deployments.

## Why State Matters
Terraform uses state to remember what resources it manages. If state is lost, corrupted, or split incorrectly, Terraform can drift from reality.

## Key Concepts
- Local state file: `terraform.tfstate`
- Remote backend: safer for teams
- Locking: prevents simultaneous conflicting changes
- Drift: when real infrastructure differs from Terraform state

## Common Commands
```bash
terraform state list
terraform state show <resource>
terraform refresh
```

## Operational Risks
- Editing state manually without a backup
- Running Terraform from multiple copies of the same codebase
- No remote locking in a team environment
- Importing resources poorly

## Safe Practices
- Back up state before risky work
- Use remote state for shared environments
- Review drift before applying fixes
- Avoid casual manual changes in the cloud portal

## Validation
- state file exists and is healthy
- resources in state match actual infrastructure
- no unexplained drift exists
