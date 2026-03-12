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

$weekPlanPath = Join-Path $RepoPath "docs\08-12-week-plan"
$labsPath     = Join-Path $RepoPath "docs\09-cyber-range-labs"
$scriptsPath  = Join-Path $RepoPath "docs\10-scripts"

Ensure-Directory -Path $weekPlanPath
Ensure-Directory -Path $labsPath
Ensure-Directory -Path $scriptsPath

Write-Section "Building 12-week plan files"

$weekPlanReadme = @'
# 08 - 12 Week Plan

## Purpose
This section provides a structured 12-week development plan for a systems engineer entering a mixed Linux, Windows, Azure, Terraform, and compliance-focused environment.

## Operational Focus
- Fast infrastructure ramp-up
- Linux operations confidence
- Terraform fundamentals
- Azure operational competence
- STIG troubleshooting
- Patch and upgrade readiness
- Vulnerability remediation workflow
- Practical lab repetition

## Recommended Usage
Use these files as your weekly execution guide. Adjust them based on what you discover in your actual environment.

## Files
- `weeks-01-04.md`
- `weeks-05-08.md`
- `weeks-09-12.md`
'@

$weeks0104 = @'
# Weeks 1-4

## Objective
Survive the first month, learn the environment, and establish operational awareness.

## Week 1 - Environment Discovery
### Goals
- Build a system inventory
- Identify Linux, Windows, Azure, and Terraform touchpoints
- Learn who owns what
- Identify monitoring, patching, and backup systems

### Study Topics
- Linux basics
- Service management
- Existing infrastructure diagrams
- Ticket and change processes

### Hands-On Tasks
- Collect server lists
- Review runbooks and diagrams
- Validate access methods
- Identify critical systems

### Validation
- You can explain the major systems at a high level
- You know where logs, docs, and monitoring live

## Week 2 - Linux Foundations
### Goals
- Build confidence with Linux navigation and troubleshooting
- Understand services, logs, networking, and disk usage

### Study Topics
- `systemctl`
- `journalctl`
- `ss`
- `df`, `du`, `lsblk`
- permissions and sudo

### Hands-On Tasks
- Troubleshoot a failed service in lab
- Practice log review
- Practice network checks
- Practice disk usage triage

### Validation
- You can diagnose a service issue methodically

## Week 3 - STIG and Security Baseline Awareness
### Goals
- Understand why hardening breaks systems
- Learn how to validate security changes safely

### Study Topics
- STIG concepts
- SSH hardening
- SELinux basics
- firewall review
- least privilege

### Hands-On Tasks
- Review hardening docs
- Compare service before/after config changes
- Practice access validation after security changes

### Validation
- You can explain common hardening breakpoints

## Week 4 - Terraform and Azure Introduction
### Goals
- Understand the structure of infrastructure-as-code
- Learn Azure resource basics

### Study Topics
- Terraform init/plan/apply
- providers/resources/variables
- Azure VMs, VNets, NSGs, RBAC

### Hands-On Tasks
- Read existing Terraform code if available
- Run a safe Terraform lab
- Review Azure VM and network inventory

### Validation
- You can explain what a Terraform plan is doing
'@

$weeks0508 = @'
# Weeks 5-8

## Objective
Move from basic awareness to practical operational confidence.

## Week 5 - Terraform Execution
### Goals
- Work comfortably with Terraform basics
- Understand state and validation

### Study Topics
- remote state
- modules
- variable files
- plan review
- drift awareness

### Hands-On Tasks
- Run `terraform fmt`
- Run `terraform validate`
- Review a module structure
- Build or modify a simple Azure example

### Validation
- You can review a basic Terraform change without guessing

## Week 6 - Azure Operations
### Goals
- Build confidence in Azure VM and network administration
- Understand monitoring and access control

### Study Topics
- VM deployment workflow
- NSGs
- subnet design
- RBAC
- Azure Monitor

### Hands-On Tasks
- Review VM settings in portal or CLI
- Practice network troubleshooting
- Review role assignments
- Review monitoring signals

### Validation
- You can trace a VM from resource group to network and access model

## Week 7 - Upgrade and Patch Readiness
### Goals
- Build a safe upgrade workflow
- Learn rollback thinking

### Study Topics
- maintenance windows
- pre-upgrade checklist
- rollback decisions
- post-change validation

### Hands-On Tasks
- Build a mock upgrade checklist
- Practice pre/post validation commands
- Simulate failed service recovery after a change

### Validation
- You can explain how to execute a safer upgrade

## Week 8 - Vulnerability Remediation Workflow
### Goals
- Build a practical workflow for scan analysis and patching

### Study Topics
- severity vs actual risk
- compensating controls
- patch validation
- evidence capture

### Hands-On Tasks
- Review sample findings
- Rank them by real risk
- Practice patch validation steps
- Capture before/after evidence

### Validation
- You can explain how a vulnerability moves from finding to closure
'@

$weeks0912 = @'
# Weeks 9-12

## Objective
Shift from learning mode toward ownership, consistency, and trustworthiness.

## Week 9 - Incident-Style Troubleshooting
### Goals
- Improve speed and discipline during outages

### Study Topics
- service failure workflow
- port checks
- log correlation
- disk pressure scenarios

### Hands-On Tasks
- Simulate service outage
- Simulate bad config
- Simulate port not listening
- Document recovery steps

### Validation
- You can troubleshoot with a repeatable pattern

## Week 10 - Documentation and Runbook Improvement
### Goals
- Turn what you know into reusable documentation

### Study Topics
- runbook structure
- validation checklists
- lessons learned capture

### Hands-On Tasks
- Improve one admin document
- Create a checklist from a repeated task
- Write a recovery note from a lab

### Validation
- Your documentation helps someone else succeed

## Week 11 - Automation Discipline
### Goals
- Automate repeated checks safely

### Study Topics
- Bash health checks
- Azure CLI inventory
- Terraform validation steps
- defensive scripting basics

### Hands-On Tasks
- Run health check script
- Improve script output
- Capture clear validation messages
- Avoid destructive defaults

### Validation
- Scripts save time without hiding important detail

## Week 12 - Consolidation and Expert Positioning
### Goals
- Become the person who understands systems, risks, and operational patterns

### Study Topics
- system relationships
- recurring failure patterns
- patch / upgrade readiness
- communication of technical risk

### Hands-On Tasks
- Review your notes
- Identify top recurring issues
- Summarize system dependencies
- Build next-step learning plan

### Validation
- You can explain the environment, common risks, and next priorities clearly
'@

Write-Utf8File -Path (Join-Path $weekPlanPath "README.md") -Content $weekPlanReadme
Write-Utf8File -Path (Join-Path $weekPlanPath "weeks-01-04.md") -Content $weeks0104
Write-Utf8File -Path (Join-Path $weekPlanPath "weeks-05-08.md") -Content $weeks0508
Write-Utf8File -Path (Join-Path $weekPlanPath "weeks-09-12.md") -Content $weeks0912

Write-Section "Building cyber range lab files"

$labsReadme = @'
# 09 - Cyber Range Labs

## Purpose
This section provides practical single-VM lab exercises that simulate real systems administration work.

## Design Constraint
These labs are intentionally designed for environments where only one VM can be used at a time.

## Operational Focus
- Linux administration
- Service troubleshooting
- Disk pressure recovery
- Patching workflow
- STIG validation
- Terraform learning flow

## Recommended Usage
Run the labs, document what happened, then update the associated docs in this repository.

## Files
- `lab-01-linux-baseline.md`
- `lab-02-service-failure.md`
- `lab-03-disk-pressure.md`
- `lab-04-patching.md`
- `lab-05-stig-hardening.md`
- `lab-06-terraform-workflow.md`
'@

$lab01 = @'
# Lab 01 - Linux Baseline

## Objective
Establish a healthy Linux baseline and verify core admin checks.

## Prerequisites
- Access to a Linux VM
- sudo access
- basic shell familiarity

## Tasks
1. Confirm hostname and uptime
2. Review running services
3. Check disk usage
4. Check IP addressing and routes
5. Review recent logs
6. Confirm firewall state
7. Record findings

## Suggested Commands
```bash
hostnamectl
uptime
systemctl --failed
df -h
lsblk
ip addr
ip route
journalctl -p err -b
firewall-cmd --state
```

## Expected Outcome
You can describe the VM's current health and baseline configuration.

## Validation
- No unexplained failed services
- Disk is healthy
- Network is understood
- No major boot errors are present
'@

$lab02 = @'
# Lab 02 - Service Failure

## Objective
Simulate and troubleshoot a failed service using a repeatable workflow.

## Prerequisites
- Linux VM
- a service you can safely stop/start or misconfigure in lab

## Tasks
1. Identify the target service
2. Stop or break the service safely
3. Review service status
4. Review logs
5. Fix the issue
6. Restart and validate

## Suggested Commands
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
ss -tulpn
```

## Failure Ideas
- bad config syntax
- wrong file permissions
- service disabled
- port conflict

## Validation
- Service starts successfully
- Logs are clean after fix
- Expected port or app behavior is restored
'@

$lab03 = @'
# Lab 03 - Disk Pressure

## Objective
Practice detecting and resolving disk usage problems.

## Prerequisites
- Linux VM
- safe location for test files

## Tasks
1. Record current disk usage
2. Create test files to consume space
3. Re-check filesystem usage
4. Identify largest consumers
5. Clean up safely
6. Validate recovery

## Suggested Commands
```bash
df -h
du -sh /*
find /var/log -type f -size +100M
find / -xdev -type f -size +500M 2>/dev/null
```

## Safety Notes
- Do not fill critical filesystems completely
- Use a controlled test directory if possible

## Validation
- You can identify the source of disk growth
- Disk usage returns to normal after cleanup
'@

$lab04 = @'
# Lab 04 - Patching

## Objective
Practice a controlled patching workflow with pre-checks and post-validation.

## Prerequisites
- Linux VM
- patch-capable package manager
- reboot allowed if needed

## Tasks
1. Record current package and service baseline
2. Check available updates
3. Apply updates
4. Reboot if required
5. Re-run validation checks
6. Document results

## Suggested Commands
```bash
dnf check-update
dnf update -y
rpm -qa | sort
systemctl --failed
journalctl -p err -b
```

## Validation
- Updates applied successfully
- System came back cleanly
- Services are healthy
- No major new errors were introduced
'@

$lab05 = @'
# Lab 05 - STIG Hardening

## Objective
Practice validating security changes and identifying operational breakpoints.

## Prerequisites
- Linux VM
- safe test changes only
- ability to recover access if SSH settings are changed

## Tasks
1. Record baseline access and service behavior
2. Apply a limited hardening change
3. Test access and application behavior
4. Review logs and denials
5. Adjust safely if needed
6. Document the impact

## Suggested Commands
```bash
systemctl status sshd
cat /etc/ssh/sshd_config
sshd -t
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
journalctl -xe
```

## Validation
- You can identify what changed
- You can explain why the change affected behavior
- You can restore working access safely
'@

$lab06 = @'
# Lab 06 - Terraform Workflow

## Objective
Practice the Terraform workflow from validation through cleanup.

## Prerequisites
- Terraform installed
- Azure credentials or a local safe Terraform example
- non-production test context only

## Tasks
1. Review the code
2. Run format and validation
3. Run a plan
4. Review the plan carefully
5. Apply if safe
6. Validate resources or outputs
7. Destroy if this is a temporary lab

## Suggested Commands
```bash
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply
terraform destroy
```

## Validation
- Plan output is understood before apply
- Resources or outputs match expectation
- Cleanup is completed if lab is temporary
'@

Write-Utf8File -Path (Join-Path $labsPath "README.md") -Content $labsReadme
Write-Utf8File -Path (Join-Path $labsPath "lab-01-linux-baseline.md") -Content $lab01
Write-Utf8File -Path (Join-Path $labsPath "lab-02-service-failure.md") -Content $lab02
Write-Utf8File -Path (Join-Path $labsPath "lab-03-disk-pressure.md") -Content $lab03
Write-Utf8File -Path (Join-Path $labsPath "lab-04-patching.md") -Content $lab04
Write-Utf8File -Path (Join-Path $labsPath "lab-05-stig-hardening.md") -Content $lab05
Write-Utf8File -Path (Join-Path $labsPath "lab-06-terraform-workflow.md") -Content $lab06

Write-Section "Building scripts documentation files"

$scriptsReadme = @'
# 10 - Scripts

## Purpose
This section tracks useful script patterns for systems administration work.

## Operational Focus
- Bash admin helpers
- PowerShell admin helpers
- Terraform command flow
- Azure CLI operational usage
- Troubleshooting script ideas

## Recommended Usage
Use these docs to capture working script ideas, validation notes, and safe usage patterns before building production-grade automation.

## Files
- `bash.md`
- `powershell.md`
- `terraform.md`
- `azure-cli.md`
- `troubleshooting.md`
'@

$bashDoc = @'
# Bash

## Purpose
Capture Bash patterns useful for Linux administration and health checks.

## Common Use Cases
- disk usage checks
- failed service checks
- uptime and host context
- package status review
- quick evidence capture

## Example Health Check
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Hostname ==="
hostname

echo "=== Uptime ==="
uptime

echo "=== Disk Usage ==="
df -h

echo "=== Failed Services ==="
systemctl --failed || true
```

## Script Design Rules
- fail clearly
- avoid silent destructive actions
- log useful output
- make validation obvious
- keep scripts readable

## Validation
- script runs cleanly
- output is understandable
- failures are visible
'@

$powershellDoc = @'
# PowerShell

## Purpose
Capture PowerShell patterns useful for Windows administration and inventory.

## Common Use Cases
- running service checks
- server inventory
- event log review
- patch or version checks
- quick environment reporting

## Example Inventory Script
```powershell
Write-Host "=== Computer Info ==="
Get-ComputerInfo | Select-Object CsName, WindowsProductName, OsVersion

Write-Host "`n=== Running Services ==="
Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object -First 20

Write-Host "`n=== Disk Usage ==="
Get-PSDrive -PSProvider FileSystem
```

## Script Design Rules
- be explicit with output
- avoid hidden assumptions
- prefer readable objects when possible
- capture before/after evidence for changes

## Validation
- output is meaningful
- script is safe to run repeatedly
- no unnecessary side effects
'@

$terraformDoc = @'
# Terraform

## Purpose
Document the practical Terraform command flow and safe usage habits.

## Core Workflow
```bash
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply
terraform destroy
```

## Admin Rules
- read the code before plan
- read the plan before apply
- understand target subscription or environment
- avoid casual state manipulation
- treat destroy carefully

## Common Notes to Capture
- provider requirements
- variable file usage
- state location
- module dependencies
- output interpretation

## Validation
- plan is understood
- apply matches expectation
- cleanup is deliberate
'@

$azureCliDoc = @'
# Azure CLI

## Purpose
Capture useful Azure CLI commands for inventory, validation, and troubleshooting.

## Common Use Cases
- list VMs
- inspect resource groups
- review NSGs
- review role assignments
- check monitoring-related resources

## Example Commands
```bash
az account show
az group list -o table
az vm list -o table
az network nsg list -o table
az role assignment list --all -o table
```

## Usage Rules
- confirm subscription context first
- prefer read-only commands when investigating
- capture outputs for evidence when useful
- avoid destructive commands without validation

## Validation
- command output matches expected environment
- subscription and scope are correct
'@

$troubleshootingDoc = @'
# Troubleshooting

## Purpose
Track script and command patterns that support repeatable troubleshooting.

## Common Areas
- failed services
- ports not listening
- disk pressure
- bad config
- network reachability
- post-patch validation

## Example Linux Triage Commands
```bash
systemctl --failed
journalctl -xe
ss -tulpn
df -h
ip addr
ip route
```

## Example Windows Triage Commands
```powershell
Get-Service | Where-Object {$_.Status -ne "Running"}
Get-WinEvent -LogName System -MaxEvents 50
Get-PSDrive -PSProvider FileSystem
ipconfig /all
```

## Documentation Rules
- record what symptom triggered investigation
- record what command proved the issue
- record what fixed it
- record how success was validated

## Validation
- troubleshooting steps are repeatable
- commands are organized by symptom or subsystem
'@

Write-Utf8File -Path (Join-Path $scriptsPath "README.md") -Content $scriptsReadme
Write-Utf8File -Path (Join-Path $scriptsPath "bash.md") -Content $bashDoc
Write-Utf8File -Path (Join-Path $scriptsPath "powershell.md") -Content $powershellDoc
Write-Utf8File -Path (Join-Path $scriptsPath "terraform.md") -Content $terraformDoc
Write-Utf8File -Path (Join-Path $scriptsPath "azure-cli.md") -Content $azureCliDoc
Write-Utf8File -Path (Join-Path $scriptsPath "troubleshooting.md") -Content $troubleshootingDoc

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\08-12-week-plan\README.md",
    "docs\08-12-week-plan\weeks-01-04.md",
    "docs\08-12-week-plan\weeks-05-08.md",
    "docs\08-12-week-plan\weeks-09-12.md",
    "docs\09-cyber-range-labs\README.md",
    "docs\09-cyber-range-labs\lab-01-linux-baseline.md",
    "docs\09-cyber-range-labs\lab-02-service-failure.md",
    "docs\09-cyber-range-labs\lab-03-disk-pressure.md",
    "docs\09-cyber-range-labs\lab-04-patching.md",
    "docs\09-cyber-range-labs\lab-05-stig-hardening.md",
    "docs\09-cyber-range-labs\lab-06-terraform-workflow.md",
    "docs\10-scripts\README.md",
    "docs\10-scripts\bash.md",
    "docs\10-scripts\powershell.md",
    "docs\10-scripts\terraform.md",
    "docs\10-scripts\azure-cli.md",
    "docs\10-scripts\troubleshooting.md"
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
Write-Host "Validation passed. All training, lab, and script files were created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git add ."
Write-Host 'git commit -m "docs: build 12 week plan cyber range labs and scripts docs"'
Write-Host "git push"

