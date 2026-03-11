# Terraform Fundamentals

## Purpose
Capture the core Terraform concepts needed to read, modify, and safely apply infrastructure code.

## Core Concepts
- **Provider**: connects Terraform to a platform such as Azure
- **Resource**: infrastructure object being managed
- **Variable**: input value
- **Output**: exported value after deployment
- **Module**: reusable group of resources
- **State**: Terraform's record of managed infrastructure

## Basic Workflow
```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Example Structure
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

## Admin Mindset
Before applying changes:
- read the code
- run `terraform fmt`
- run `terraform validate`
- read the plan output carefully
- confirm impact before `apply`

## Validation
- plan output matches expectation
- resource appears in Azure after apply
- state updates cleanly
