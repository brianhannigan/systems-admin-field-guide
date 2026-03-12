param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide"
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor $Color
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory -Path $parent
    }

    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$linuxPath      = Join-Path $RepoPath "docs\02-linux-admin"
$terraformPath  = Join-Path $RepoPath "docs\03-terraform"
$stigPath       = Join-Path $RepoPath "docs\05-stig-hardening"

Ensure-Directory -Path $linuxPath
Ensure-Directory -Path $terraformPath
Ensure-Directory -Path $stigPath

Write-Section "Upgrading Linux services doc"

$linuxServices = @'
# Service Management

## Purpose
This document is a practical service troubleshooting runbook for Linux administrators working in production-minded environments.

## Why This Matters
Service failures are one of the fastest ways infrastructure issues become user-visible. A strong administrator should be able to move from symptom to root cause methodically instead of restarting blindly.

## Core systemd Commands
```bash
systemctl status <service>
systemctl restart <service>
systemctl stop <service>
systemctl start <service>
systemctl enable <service>
systemctl disable <service>
systemctl is-active <service>
systemctl is-enabled <service>
systemctl list-units --type=service
systemctl --failed
```

## First-Response Workflow
When a service is reported as down or unstable:

1. Confirm the exact service name
2. Check current service status
3. Check recent logs
4. Confirm whether the process is listening on the expected port
5. Check config syntax if supported
6. Check permissions, SELinux, and firewall behavior
7. Restart only after evidence is gathered
8. Validate that recovery is real, not just temporary

## Primary Triage Commands
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
ss -tulpn
ps aux | grep <service>
```

## Common Failure Categories

### 1. Bad Configuration
Typical symptoms:
- service fails immediately after restart
- `systemctl status` shows exit code
- logs show syntax or parsing errors

Examples:
```bash
nginx -t
sshd -t
apachectl configtest
```

### 2. Port Binding Failure
Typical symptoms:
- service appears to start then exits
- logs mention bind failure or address in use
- expected port is already used by another process

Examples:
```bash
ss -tulpn | grep :80
ss -tulpn | grep :443
lsof -i :80
```

### 3. Permission Denied
Typical symptoms:
- service account cannot read config
- app cannot write PID, lock, or log file
- logs show access denied

Examples:
```bash
ls -l /path/to/file
namei -l /path/to/file
```

### 4. SELinux Denial
Typical symptoms:
- service looks correctly configured
- permissions look fine
- logs or audit records show blocked access

Examples:
```bash
getenforce
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log
restorecon -Rv /path/to/app
```

### 5. Firewall or Network Dependency Issue
Typical symptoms:
- service is active but unreachable
- app binds only to localhost
- dependency host cannot be reached

Examples:
```bash
firewall-cmd --list-all
ss -tulpn
curl -I http://localhost
curl -I http://127.0.0.1
ping <dependency-host>
```

## Validation Pattern
Never stop at “service is active.”

Validate all of the following where applicable:

- service is active
- process is running
- expected port is listening
- local app response is healthy
- remote access works if expected
- recent logs are clean
- monitoring returns to normal

Examples:
```bash
systemctl is-active <service>
ss -tulpn
curl -I http://localhost
journalctl -u <service> -n 20 --no-pager
```

## Example Scenario: NGINX Fails After Config Change

### Symptom
Website returns error after a configuration update.

### Triage
```bash
systemctl status nginx
journalctl -u nginx -n 50 --no-pager
nginx -t
ss -tulpn | grep :80
```

### Possible Findings
- syntax error in site config
- port conflict on 80
- bad file permissions on cert or key
- SELinux denial for content path

### Recovery
```bash
nginx -t
systemctl restart nginx
curl -I http://localhost
journalctl -u nginx -n 20 --no-pager
```

## Example Scenario: SSH Access Breaks After Hardening

### Symptom
Users can no longer connect over SSH.

### Triage
```bash
systemctl status sshd
journalctl -u sshd -n 100 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
getenforce
ausearch -m avc -ts recent
```

### Common Causes
- invalid `sshd_config`
- firewall rule changed
- root login or auth method disabled unexpectedly
- SELinux denial on nonstandard path
- permissions wrong on SSH config or key files

## Operational Rules
- do not restart first and investigate later
- capture evidence before making changes
- validate using both service state and functional behavior
- document recurring patterns in the repo
- build reusable troubleshooting checklists

## Minimum Evidence to Capture
- service status output
- relevant log lines
- config test result if applicable
- port listening output
- command used to fix the issue
- proof of successful validation

## Quick Runbook Summary
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
ss -tulpn
# config test if supported
systemctl restart <service>
curl -I http://localhost
```
'@

Write-Utf8File -Path (Join-Path $linuxPath "services.md") -Content $linuxServices

Write-Section "Upgrading Terraform fundamentals doc"

$terraformFundamentals = @'
# Terraform Fundamentals

## Purpose
This document explains Terraform from an infrastructure operator's perspective: how to read it, review it safely, predict impact, and avoid common mistakes.

## Why Terraform Matters
Terraform turns infrastructure changes into reviewable code. For systems administration and platform work, that means:

- changes can be planned before execution
- intent is visible in code
- review is more disciplined
- environments can be more consistent
- drift becomes easier to identify

## Core Concepts

### Provider
The provider connects Terraform to a platform such as Azure.

Example:
```hcl
provider "azurerm" {
  features {}
}
```

### Resource
A resource is an infrastructure object Terraform manages.

Example:
```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-sysadmin-lab"
  location = "East US"
}
```

### Variable
Variables are inputs used to make code reusable and environment-aware.

Example:
```hcl
variable "location" {
  type    = string
  default = "East US"
}
```

### Output
Outputs expose useful values after deployment.

Example:
```hcl
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
```

### Module
A module is a reusable collection of Terraform code.

Common use cases:
- standard VM pattern
- standard NSG pattern
- resource group + tagging pattern
- subnet pattern

### State
Terraform state is Terraform's memory of what it manages. It is operationally sensitive and should be handled carefully.

## Basic Workflow
```bash
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply
terraform destroy
```

## Operator Review Workflow
Before applying any change:

1. Read the code
2. Identify what resources are affected
3. Confirm the target subscription or environment
4. Confirm variables and tfvars inputs
5. Run `terraform fmt`
6. Run `terraform validate`
7. Run `terraform plan`
8. Read the plan carefully
9. Only apply after the plan matches expectation

## What to Look for in a Plan
When reading `terraform plan`, verify:

- what is being created
- what is being changed in place
- what is being destroyed
- whether names, regions, and sizes are correct
- whether networking changes are broader than expected
- whether identity or access changes are included
- whether tags or standard settings are drifting

## Safe Admin Mindset
Do not treat Terraform like a magic deploy button.

Use this mindset:

- code first
- plan before apply
- understand before execute
- prefer small changes
- watch for drift
- protect state
- validate after apply

## Common Admin Mistakes
- applying without reading the plan
- working in the wrong subscription or environment
- using stale local code
- changing cloud resources manually, then forgetting drift exists
- treating state casually
- assuming “no syntax error” means “safe change”

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

## Validation Before Apply
```bash
terraform fmt
terraform validate
terraform init
terraform plan
```

## Validation After Apply
After a successful apply, verify in both Terraform and Azure:

```bash
terraform state list
terraform output
```

Then validate in Azure:
- resource exists in expected resource group
- region is correct
- naming is correct
- tags are correct
- no unexpected side effects occurred

## Reading Terraform Like an Admin
When you open Terraform code, answer these questions:

- What provider is being used?
- What subscription or environment is this targeting?
- What resources are defined here?
- What variables control behavior?
- Are modules hiding important complexity?
- Where is state stored?
- What would happen if this ran today?

## Review Checklist
- provider and environment understood
- variables reviewed
- plan reviewed carefully
- create/change/destroy actions understood
- state location understood
- validation plan exists after apply

## Example Admin Notes to Capture in This Repo
As you gain experience, update this document with:
- actual plan patterns from your environment
- safe review habits your team uses
- known module conventions
- common drift situations
- mistakes that caused rework

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
'@

Write-Utf8File -Path (Join-Path $terraformPath "fundamentals.md") -Content $terraformFundamentals

Write-Section "Upgrading STIG troubleshooting doc"

$stigTroubleshooting = @'
# STIG Troubleshooting

## Purpose
This document provides a repeatable workflow for diagnosing systems that break after hardening changes, policy tightening, or baseline enforcement.

## Why This Matters
STIG implementation often improves security while introducing operational friction. Services may stop working not because the system is “bad,” but because a dependency, permission, access path, or policy assumption changed.

A strong administrator should be able to answer:

- what changed
- what broke
- why it broke
- how to restore function safely
- how to preserve compliance or document exceptions

## Core Troubleshooting Workflow

1. Identify exactly what changed
2. Identify exactly what broke
3. Confirm whether the issue is service, access, or application behavior
4. Review logs and denials
5. Compare before/after settings if possible
6. Validate permissions, authentication, SELinux, and firewall behavior
7. Apply the smallest safe corrective action
8. Re-test functionality
9. Capture evidence and determine whether an exception is required

## First Commands to Run
```bash
systemctl status <service>
journalctl -xe
journalctl -u <service> -n 100 --no-pager
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
id <service-account>
```

## What to Ask First
- What hardening change was applied?
- Was the system working before the change?
- Did the issue affect remote access, application behavior, or both?
- Did the service fail to start or start incorrectly?
- Did logging, file access, or network reachability change?
- Did authentication or account policy change?

## Most Common Break Categories

### 1. SSH / Remote Access Breakage
Typical causes:
- `sshd_config` settings changed
- root login disabled unexpectedly
- old auth method no longer allowed
- firewall port rule removed or changed
- crypto restrictions affect older clients

Useful commands:
```bash
systemctl status sshd
journalctl -u sshd -n 100 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
```

### 2. Permission or Ownership Breakage
Typical causes:
- service account lost access to config, temp, PID, or log path
- tighter file mode broke app startup
- inherited path permissions prevent execution or reads

Useful commands:
```bash
ls -l /path/to/file
namei -l /path/to/file
id <service-account>
sudo -u <service-account> test -r /path/to/file && echo readable
```

### 3. SELinux Denials
Typical causes:
- app moved to nonstandard path
- web service needs content context restored
- daemon attempts action outside allowed type behavior

Useful commands:
```bash
getenforce
sestatus
ausearch -m avc -ts recent
restorecon -Rv /path/to/content
```

### 4. Firewall / Network Restriction
Typical causes:
- required port no longer allowed
- zone assignment changed
- service binds correctly but path is blocked

Useful commands:
```bash
firewall-cmd --list-all
firewall-cmd --list-ports
ss -tulpn
curl -I http://localhost
```

### 5. Service Account / Auth Policy Breakage
Typical causes:
- account restrictions changed
- password rules affect service startup
- PAM or login policy blocks automation or access

Useful checks:
- service unit account
- PAM changes
- authentication logs
- lockout or shell restrictions

## Example Scenario: SSH Breaks After Hardening

### Symptom
Users cannot connect after a hardening update.

### Workflow
```bash
systemctl status sshd
journalctl -u sshd -n 100 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
```

### Likely Causes
- invalid SSH configuration
- stricter auth settings
- firewall rule changed
- user access assumptions invalidated

### Safe Response
- confirm exact config error
- restore a working access method
- document which control caused impact
- retest with intended auth path

## Example Scenario: Web Service Starts but Site Is Broken

### Symptom
Service is active, but the application does not function correctly.

### Workflow
```bash
systemctl status nginx
journalctl -u nginx -n 100 --no-pager
ls -l /var/www/html
getenforce
ausearch -m avc -ts recent
curl -I http://localhost
```

### Likely Causes
- content path permission problem
- SELinux context issue
- log or temp path write restriction
- app dependency denied access

## Example Scenario: App Fails After Permission Tightening

### Symptom
A service fails on restart after a security baseline is applied.

### Workflow
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
ls -l /path/to/app/config
id <service-account>
namei -l /path/to/app/config
```

### Likely Causes
- app user cannot read config
- app user cannot write runtime directory
- inherited parent directory permission changed

## Safe Fix Pattern
Use the smallest safe corrective action that restores required function.

Good pattern:
1. prove root cause
2. fix only the required setting
3. re-test
4. document the change
5. determine whether this is compliant, compensating, or exception-worthy

## Evidence to Capture
For every hardening-related fix, capture:

- what rule or change was involved
- what symptom occurred
- what commands proved the issue
- what corrective action was taken
- what validation proved recovery
- whether an exception or compensating control is needed

## Exception Thinking
Sometimes a control cannot be applied cleanly to a mission-critical workload. When that happens, document:

- business impact
- technical reason
- security risk introduced
- compensating controls
- approval path if required

## Validation Checklist
- service starts correctly
- access works as intended
- expected ports are reachable
- logs are clean after the fix
- compliance impact is understood
- evidence is documented

## Quick Runbook Summary
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
```
'@

Write-Utf8File -Path (Join-Path $stigPath "troubleshooting.md") -Content $stigTroubleshooting

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\02-linux-admin\services.md",
    "docs\03-terraform\fundamentals.md",
    "docs\05-stig-hardening\troubleshooting.md"
)

$missing = @()

foreach ($relativeFile in $expectedFiles) {
    $fullPath = Join-Path $RepoPath $relativeFile
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $missing += $relativeFile
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing files detected:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    throw "Validation failed."
}

Write-Host ""
Write-Host "Validation passed. Core portfolio docs were upgraded successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git add ."
Write-Host 'git commit -m "docs: upgrade core linux terraform and stig portfolio docs"'
Write-Host "git push"

