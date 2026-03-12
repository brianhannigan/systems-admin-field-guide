# Terraform Fundamentals

## Purpose
This document explains Terraform from an infrastructure operator's point of view: how to read it, review it safely, predict its impact, and avoid common mistakes.

## Why Terraform Matters
Terraform makes infrastructure changes visible before they happen. That is valuable because it allows:

- review before execution
- repeatable infrastructure creation
- clearer change intent
- reduced manual drift
- better auditability of changes

## Core Concepts

### Provider
A provider connects Terraform to a platform such as Azure.

```hcl
provider "azurerm" {
  features {}
}
```

### Resource
A resource is an object Terraform manages.

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-sysadmin-lab"
  location = "East US"
}
```

### Variable
Variables make infrastructure configurable and reusable.

```hcl
variable "location" {
  type    = string
  default = "East US"
}
```

### Output
Outputs expose useful results after apply.

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
```

### Module
A module is a reusable bundle of Terraform code.

Typical module use cases:
- standard VM build
- NSG pattern
- subnet pattern
- tagging standard

### State
State is Terraform's record of what it manages. It is operationally sensitive and must be treated carefully.

## Standard Workflow
```bash
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply
terraform destroy
```

## Operator Review Workflow

### 1. Read the Code
Understand:
- provider
- target environment
- variables
- modules
- resources affected

### 2. Validate Structure
```bash
terraform fmt
terraform validate
```

### 3. Initialize Providers and Backend
```bash
terraform init
```

### 4. Review the Plan
```bash
terraform plan
```

### 5. Read the Plan Carefully
Check:
- creates
- in-place updates
- destroys
- naming
- region
- networking
- tags
- identity changes
- unexpected deletes

### 6. Apply Only After the Plan Makes Sense
```bash
terraform apply
```

### 7. Validate in Terraform and in Azure
```bash
terraform state list
terraform output
```

Then confirm the real environment matches expectation.

## Admin Mindset
Do not treat Terraform as a “click deploy” tool.

Use this mindset:
- understand before apply
- plan before apply
- protect state
- use small, reviewable changes
- assume drift exists until disproven
- validate after apply

## Common Mistakes
- applying without reading the plan
- working in the wrong environment
- stale code or stale variables
- manual portal changes causing drift
- careless state handling
- assuming validate means safe

## Small Azure Example
```hcl
terraform {
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-sysadmin-lab"
  location = "East US"
}
```

## Review Checklist
- provider understood
- environment understood
- variables reviewed
- modules reviewed
- plan reviewed
- create/change/destroy actions understood
- state location known
- post-apply validation steps known

## Quick Reference
```bash
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply
terraform state list
terraform output
```