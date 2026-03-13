# Scenario â€” Terraform Drift Detected

## Problem
The deployed infrastructure no longer matches the Terraform configuration or state.

## Environment
- Azure resources managed with Terraform
- Shared engineering environment
- State stored locally or remotely

## Symptoms
- terraform plan shows unexpected changes
- Resources differ from expected naming, tags, or settings
- Manual portal changes were made outside code

## Investigation Steps
1. Run terraform plan and capture proposed changes
2. Compare state with actual deployed resources
3. Review recent portal, CLI, or script-based changes
4. Confirm workspace and backend configuration
5. Identify whether drift should be adopted or reverted

## Common Root Causes
- Manual changes in portal
- Wrong workspace or backend
- State corruption or partial apply
- Configuration drift after hotfixes
- Resource import never completed

## Resolution
Document the chosen path:
- Reconcile code to match approved reality
- Revert manual changes to match code
- Import resources into state when needed
- Re-run plan and apply carefully

## Validation
- terraform plan returns expected output
- State matches deployed resources
- Team agrees on source of truth
- Change history is documented

## Lessons Learned
Capture how to reduce future drift through process and automation.
