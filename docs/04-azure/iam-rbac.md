# IAM and RBAC

## Purpose
Track how Azure identity and access should be understood and validated by a systems administrator.

## Core Concepts
- Azure AD / Entra identity context
- Role-Based Access Control (RBAC)
- Scope: management group, subscription, resource group, resource
- Least privilege
- Role assignment review

## Common Roles to Understand
- Reader
- Virtual Machine Contributor
- Network Contributor
- Contributor
- Owner

## Key Questions
- Who has access?
- At what scope is access assigned?
- Is the access broader than necessary?
- Are service principals or automation identities in use?
- Are there stale or inherited permissions?

## Azure CLI Examples
```bash
az role assignment list --all -o table
az role assignment list --assignee user@domain.com -o table
az role definition list --name Contributor -o json
```

## Validation Checklist
- Access is scoped appropriately
- Elevated roles are justified
- Automation identities are documented
- Unexpected assignments are investigated
- Least privilege is being followed

## Common Problems
- Overly broad Contributor or Owner access
- Unknown inherited permissions
- Untracked service principals
- Access granted at subscription scope when resource group scope was enough
