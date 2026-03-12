param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-admin-field-guide"
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

    [System.IO.File]::WriteAllText(
        $Path,
        $Content,
        (New-Object System.Text.UTF8Encoding($false))
    )
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$azurePath   = Join-Path $RepoPath "docs\04-azure"
$upgradePath = Join-Path $RepoPath "docs\06-server-upgrades"
$vulnPath    = Join-Path $RepoPath "docs\07-vulnerability-management"
$tfPath      = Join-Path $RepoPath "docs\03-terraform"

Ensure-Directory -Path $azurePath
Ensure-Directory -Path $upgradePath
Ensure-Directory -Path $vulnPath
Ensure-Directory -Path $tfPath

Write-Section "Upgrading Azure VM deployment"

$azureVmDeployment = @'
# VM Deployment

## Purpose
This document provides a practical Azure VM deployment and validation workflow for systems administrators supporting cloud-hosted infrastructure.

## Why This Matters
A VM deployment is not complete when the platform says “Succeeded.” It is only complete when:
- the VM is in the right resource group and region
- the network design is correct
- access is configured intentionally
- disks and monitoring are appropriate
- the guest OS is reachable and healthy

## Core Deployment Decisions

### Resource Group
Choose the correct resource group for:
- ownership
- lifecycle
- billing or organizational alignment
- role assignment scope

### Region
Validate:
- correct geography
- compliance constraints
- latency considerations
- resource availability

### VM Size
Choose based on:
- CPU and memory needs
- workload profile
- expected growth
- cost constraints

### OS Image
Validate:
- Linux vs Windows
- baseline image source
- patch status
- hardening requirements
- support lifecycle

### Disk Strategy
Consider:
- OS disk type
- data disk needs
- backup integration
- expected performance profile

### Access Method
Decide intentionally:
- SSH key vs password for Linux
- public vs private access
- jump box or bastion use
- admin account naming standard

### Tagging and Naming
Apply consistent:
- naming pattern
- environment tag
- owner tag
- application tag
- cost or ops tags if used

## Practical Portal Workflow
1. Create or select the resource group
2. Set VM name and region
3. Choose image and size
4. Configure admin access
5. Attach correct network settings
6. Review disk configuration
7. Review monitoring/management options
8. Validate before create
9. Deploy and confirm resource health

## Useful Azure CLI Commands

    az vm list -o table
    az vm show --name MyVm --resource-group MyRg
    az vm start --name MyVm --resource-group MyRg
    az vm stop --name MyVm --resource-group MyRg
    az vm restart --name MyVm --resource-group MyRg
    az vm get-instance-view --name MyVm --resource-group MyRg

## Post-Deployment Validation

### Platform Validation
Confirm:
- VM exists in correct resource group
- region is correct
- size is correct
- NIC and disk attachments are correct
- public IP exists only if intended

### Access Validation
Confirm:
- SSH or RDP works
- NSGs align with intended access
- admin method is documented
- the guest OS responds as expected

### Guest Validation
Inside the VM, validate:
- hostname and identity
- expected services
- network behavior
- disk layout
- no immediate errors after boot

Example Linux checks:

    hostnamectl
    uptime
    systemctl --failed
    ip addr
    df -h
    journalctl -p err -b

## Common Deployment Mistakes
- wrong region
- wrong size
- wrong VNet or subnet
- public IP attached unintentionally
- tags missing
- monitoring not enabled
- admin access method poorly planned

## Minimum Evidence to Capture
- resource group
- region
- VM size
- NIC/IP details
- access method
- initial validation output
- ticket or change reference if applicable

## Quick Runbook

    az vm show --name MyVm --resource-group MyRg
    az vm get-instance-view --name MyVm --resource-group MyRg
    az network nic list -o table

    # Then validate inside the guest
    hostnamectl
    uptime
    systemctl --failed
    df -h
'@
Write-Utf8File -Path (Join-Path $azurePath "vm-deployment.md") -Content $azureVmDeployment

Write-Section "Upgrading Azure IAM and RBAC"

$azureRbac = @'
# IAM and RBAC

## Purpose
This document explains Azure IAM and RBAC from a systems administration perspective, focusing on access scope, least privilege, and operational validation.

## Why This Matters
Access problems in Azure are often scope problems. Too much access creates security risk; too little access blocks operations. Administrators need to understand who can do what, where, and why.

## Core Concepts

### RBAC
Role-Based Access Control determines what actions a principal can perform on Azure resources.

### Scope
Access can be assigned at:
- management group
- subscription
- resource group
- resource

### Principal Types
Common principal types include:
- users
- groups
- service principals
- managed identities

## Common Built-In Roles
- Reader
- Virtual Machine Contributor
- Network Contributor
- Contributor
- Owner

## Least Privilege Thinking
Prefer:
- narrow scope
- role aligned to actual task
- group-based assignment where practical
- documented service identities

Avoid:
- unnecessary Owner access
- Contributor at subscription scope when resource-group scope is enough
- stale role assignments that no one can justify

## Practical Review Questions
- Who currently has access?
- At what scope is that access granted?
- Is the scope broader than required?
- Are service principals or automation identities documented?
- Are there inherited permissions that create risk?
- Are there old assignments that should be removed?

## Useful Azure CLI Commands

    az role assignment list --all -o table
    az role assignment list --assignee user@domain.com -o table
    az role definition list --name Contributor -o json
    az ad sp list --display-name MyAppIdentity

## Practical RBAC Review Workflow

### 1. Identify the Resource or Resource Group
Know exactly what you are reviewing.

### 2. Identify Principals With Access
List current assignments and note broad roles first.

### 3. Review Scope
Ask whether access is assigned at:
- subscription
- resource group
- specific resource

### 4. Validate Need
For each elevated assignment, ask:
- what task requires this?
- is there a lower role that would work?
- is the principal still active and needed?

### 5. Review Automation Identities
For service principals or managed identities, document:
- purpose
- owner
- scope
- role
- dependency

## Common RBAC Problems
- too many Owners
- Contributor at overly broad scope
- no documentation for service principals
- stale assignments from old projects
- troubleshooting blocked because no one knows where permissions are inherited from

## Validation Checklist
- role assignments are understood
- scope is appropriate
- least privilege is followed where practical
- stale or unjustified assignments are flagged
- automation identities are documented

## Quick Runbook

    az role assignment list --all -o table
    az role assignment list --assignee user@domain.com -o table
    az role definition list --name Reader -o json
'@
Write-Utf8File -Path (Join-Path $azurePath "iam-rbac.md") -Content $azureRbac

Write-Section "Upgrading rollback planning"

$rollbackPlanning = @'
# Rollback Planning

## Purpose
This document defines how to think about rollback before a server upgrade, patch event, or major configuration change.

## Why This Matters
Rollback is not an afterthought. It is part of the change plan. A change without a realistic rollback path is a gamble, especially when systems are critical or fragile.

## Core Rollback Questions
Before the change starts, answer:
- what failure conditions trigger rollback?
- who decides when rollback happens?
- what restore point exists?
- how long will rollback take?
- what validation proves the system is restored?

## Common Rollback Options
- restore VM snapshot
- restore backup
- revert package version if supported
- revert config files
- fail back to alternate node
- restore network or access configuration

## Rollback Decision Triggers
Rollback should be considered when:
- service will not start
- application health check fails
- critical dependency is broken
- access path is lost
- performance degradation is severe
- security logging or required controls are lost unexpectedly
- validation cannot be completed successfully in the change window

## Practical Rollback Workflow

### 1. Define the Restore Point
Document:
- snapshot time
- backup job or restore point
- version baseline
- critical config copies if used

### 2. Define the Trigger
Do not wait for panic. Decide ahead of time what counts as failure.

Examples:
- service unavailable after two validated recovery attempts
- critical app validation fails
- system cannot boot cleanly
- required user path unavailable after change

### 3. Define the Decision Authority
Know who can say:
- continue
- pause
- rollback now

### 4. Define the Technical Steps
Write them down clearly:
- what command or platform action restores the system?
- what order should actions occur in?
- what dependencies must be restored first?

### 5. Define Validation After Rollback
Rollback is not complete until you verify:
- service is back
- app works
- logs are healthy
- monitoring is normal

## Example Rollback Evidence
Capture:
- snapshot or backup reference
- failed validation evidence
- rollback start time
- rollback completion time
- validation outputs after restore

## Common Rollback Mistakes
- backup assumed but not confirmed
- no clear trigger threshold
- no owner assigned for the decision
- rollback slower than maintenance window allowed
- rollback completed but not validated
- team restores platform state but ignores guest or app health

## Validation Checklist
- restore point exists and is verified
- rollback triggers are defined
- owner/authority is defined
- technical steps are documented
- post-rollback validation exists

## Quick Runbook
- identify restore point
- identify rollback trigger
- identify approver
- document restore steps
- validate service and application health after restore
'@
Write-Utf8File -Path (Join-Path $upgradePath "rollback-planning.md") -Content $rollbackPlanning

Write-Section "Upgrading scan analysis"

$vulnScanAnalysis = @'
# Scan Analysis

## Purpose
This document explains how to review vulnerability scan results in a way that is technically accurate and operationally useful.

## Why This Matters
Scanner output is a starting point, not a final answer. Good analysis confirms the affected asset, the vulnerable component, the practical exposure, and the likely remediation path before work is prioritized.

## Core Review Areas
For each finding, review:
- severity
- CVE or plugin details
- affected host
- asset role
- exposed surface
- vulnerable package or config
- patch or mitigation availability
- potential false positive conditions

## Practical Questions to Ask
- Is this system critical?
- Is it public-facing or isolated?
- Is the vulnerable component actually installed?
- Is the vulnerable service active?
- Is the finding already mitigated by another control?
- Is this a false positive candidate?
- Is patching straightforward or risky?

## Practical Scan Analysis Workflow

### 1. Read the Finding Carefully
Identify:
- finding name
- severity
- scanner evidence
- affected package, port, or configuration

### 2. Confirm the Asset Context
Determine:
- what the host does
- whether it is production
- whether it is externally reachable
- whether it stores sensitive data or supports a critical function

### 3. Confirm the Vulnerable Component Exists
Do not assume the scanner is right.

Examples:
- package installed?
- service enabled?
- port exposed?
- config actually matches the vulnerable pattern?

### 4. Identify Remediation Path
Determine whether the response is:
- patch
- version upgrade
- config change
- service disablement
- exposure reduction
- compensating control

### 5. Note False Positive Conditions
Some findings require extra care:
- old package metadata
- library installed but not used
- service not enabled
- port seen historically but not active now
- platform-specific scanner mismatch

## Operational Notes to Record
For useful analysis, capture:
- asset name and role
- vulnerability identifier
- evidence seen
- component confirmed or disproven
- exposure level
- recommended remediation path

## Common Analysis Mistakes
- trusting scanner output without verification
- ignoring asset criticality
- ignoring exposure differences
- prioritizing only by severity number
- closing findings without proof
- patching the wrong component

## Good Scan Analysis Example
A good note should answer:
- what was found
- where it was found
- whether the component really exists
- how exposed it is
- what the best fix path is
- whether there are operational risks in fixing it

## Validation Checklist
- finding reviewed carefully
- asset context understood
- vulnerable component verified
- remediation path identified
- false positive considered
- next action assigned

## Quick Runbook
- read the scanner evidence
- identify the asset role
- verify the vulnerable component exists
- determine exposure
- identify fix or mitigation path
- record the reasoning
'@
Write-Utf8File -Path (Join-Path $vulnPath "scan-analysis.md") -Content $vulnScanAnalysis

Write-Section "Upgrading Terraform troubleshooting"

$tfTroubleshooting = @'
# Terraform Troubleshooting

## Purpose
This document provides a practical Terraform troubleshooting workflow for administrators reviewing plan failures, provider issues, state problems, and drift-related surprises.

## Why This Matters
Terraform failures often look intimidating, but most fall into a few repeatable categories:
- syntax or validation problem
- provider authentication issue
- resource argument mismatch
- dependency order problem
- state problem
- drift between code and cloud reality

## First Rule
Read the exact error. Do not skip straight to trial-and-error changes.

## Common Troubleshooting Workflow

### 1. Normalize Formatting and Syntax
Start with:

    terraform fmt
    terraform validate

If these fail, fix structure and syntax first.

### 2. Initialize Cleanly
If providers or modules are in question:

    terraform init

Check:
- provider install success
- backend access
- module download success

### 3. Review the Plan
Use:

    terraform plan

Ask:
- what resource triggered the error?
- is the target environment correct?
- is the variable input correct?
- is this a create, update, or destroy problem?

### 4. Check Provider and Credentials
Common issues:
- wrong subscription or tenant
- expired auth
- missing permissions
- provider version mismatch

Useful command:

    terraform providers

### 5. Check State
If resources behave unexpectedly, inspect state:

    terraform state list
    terraform state show <resource>

Ask:
- is the resource already tracked?
- is the state stale?
- is the real environment different from the code?

## Common Failure Categories

### Syntax / Validation Failure
Symptoms:
- validate fails
- plan never starts
- parser error or invalid block structure

Typical cause:
- malformed HCL
- wrong attribute name
- wrong block placement

### Provider Authentication Failure
Symptoms:
- plan/apply fails before resource work starts
- access denied
- subscription mismatch

Typical cause:
- incorrect login context
- insufficient permissions
- wrong provider config

### Resource Argument or Schema Error
Symptoms:
- invalid argument
- unsupported block type
- required attribute missing

Typical cause:
- outdated example
- provider version mismatch
- typo in attribute names

### Dependency / Ordering Problem
Symptoms:
- resource creation fails because dependency not ready
- reference chain incomplete
- hidden dependency not modeled

Typical cause:
- missing explicit dependency
- bad input reference
- platform timing or ordering assumption

### State Conflict
Symptoms:
- Terraform thinks resource exists differently than reality
- duplicate object or already exists behavior
- destroy/update behavior seems wrong

Typical cause:
- manual cloud changes
- stale state
- resource imported or created outside expected workflow

### Drift
Symptoms:
- plan shows unexpected changes
- configuration in portal differs from code
- tags or settings keep changing back

Typical cause:
- manual edits in cloud portal
- multiple teams changing same resources
- code and environment no longer aligned

## Practical Troubleshooting Questions
- what exact command failed?
- what exact resource is involved?
- what changed recently?
- is the provider authenticated to the expected environment?
- is this a code problem, auth problem, state problem, or cloud drift problem?

## Useful Commands

    terraform fmt
    terraform validate
    terraform init
    terraform plan
    terraform providers
    terraform state list
    terraform state show <resource>

## Good Troubleshooting Discipline
- fix one class of problem at a time
- read the exact error text
- re-run plan after each meaningful fix
- avoid random manual portal changes mid-investigation
- document repeated error patterns in this repo

## Validation Checklist
- error category identified
- fix applied deliberately
- plan runs cleanly
- apply only attempted after plan is understood
- post-fix behavior documented

## Quick Runbook

    terraform fmt
    terraform validate
    terraform init
    terraform plan
    terraform providers
    terraform state list
'@
Write-Utf8File -Path (Join-Path $tfPath "troubleshooting.md") -Content $tfTroubleshooting

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\04-azure\vm-deployment.md",
    "docs\04-azure\iam-rbac.md",
    "docs\06-server-upgrades\rollback-planning.md",
    "docs\07-vulnerability-management\scan-analysis.md",
    "docs\03-terraform\troubleshooting.md"
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
Write-Host "Validation passed. The next batch of Azure, rollback, scan analysis, and Terraform docs were upgraded successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "docs: upgrade azure vm deployment rbac rollback scan analysis and terraform troubleshooting docs"'
Write-Host "git push"
