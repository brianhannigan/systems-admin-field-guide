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

    [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $parent | ForEach-Object { Join-Path $_ (Split-Path $Path -Leaf) }), $Content, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$stigPath   = Join-Path $RepoPath "docs\05-stig-hardening"
$linuxPath  = Join-Path $RepoPath "docs\02-linux-admin"
$tfPath     = Join-Path $RepoPath "docs\03-terraform"
$azurePath  = Join-Path $RepoPath "docs\04-azure"
$vulnPath   = Join-Path $RepoPath "docs\07-vulnerability-management"

Ensure-Directory -Path $stigPath
Ensure-Directory -Path $linuxPath
Ensure-Directory -Path $tfPath
Ensure-Directory -Path $azurePath
Ensure-Directory -Path $vulnPath

Write-Section "Upgrading STIG troubleshooting"

$stigTroubleshooting = @'
# STIG Troubleshooting

## Purpose
This document provides a repeatable workflow for diagnosing systems that break after STIG hardening, baseline tightening, or security policy enforcement.

## Why This Matters
STIG changes often improve security while breaking assumptions that applications, admins, or automation previously relied on. Good troubleshooting here is not guessing. It is disciplined validation of what changed, what failed, and what minimal corrective action restores function safely.

## Primary Triage Questions
Before making any change, answer these questions:

- What STIG control or hardening action changed?
- What exact function broke?
- Did access break, did the service fail, or did the app become partially degraded?
- Is this a permissions issue, authentication issue, SELinux issue, firewall issue, or dependency issue?
- Is the break local only, remote only, or both?

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

## Standard Troubleshooting Workflow

### 1. Identify the Change
Determine exactly what was hardened:
- SSH config
- PAM or auth policy
- file permissions
- service account restrictions
- audit settings
- firewall rules
- SELinux context or enforcement behavior

### 2. Identify the Failed Behavior
Classify the symptom:
- remote access failure
- service fails to start
- service starts but app is broken
- app loses write access
- logs show denials or syntax errors
- expected traffic no longer reaches the host

### 3. Review Service State and Logs
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
```

### 4. Validate Access Path
Check whether the failure is local, remote, or both:
```bash
ss -tulpn
curl -I http://localhost
curl -I http://127.0.0.1
```

### 5. Validate Permissions and Service Identity
```bash
id <service-account>
ls -l /path/to/file
namei -l /path/to/file
sudo -u <service-account> test -r /path/to/file && echo readable
```

### 6. Validate SELinux and Firewall
```bash
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
```

### 7. Apply the Smallest Safe Fix
Do not weaken everything at once. Correct the actual blocking condition, then retest.

### 8. Capture Evidence
Record:
- what changed
- what broke
- what command proved it
- what fixed it
- what validated recovery
- whether an exception is needed

## Common Break/Fix Scenarios

### Scenario 1: SSH Access Breaks After Hardening

#### Symptom
Users cannot connect remotely after hardening is applied.

#### Triage
```bash
systemctl status sshd
journalctl -u sshd -n 100 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
```

#### Common Causes
- invalid `sshd_config`
- root login disabled unexpectedly
- key-based auth assumptions changed
- crypto restrictions break older clients
- firewall no longer allows SSH
- SELinux denial for nonstandard config path

#### Validation
- SSH daemon is active
- config test passes
- port 22 is listening
- intended login path works
- logs are clean after restart

### Scenario 2: Service Fails After Permissions Tighten

#### Symptom
A service that previously worked now fails on restart.

#### Triage
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
ls -l /path/to/config
namei -l /path/to/config
id <service-account>
```

#### Common Causes
- service account can no longer read config
- parent directory permissions block traversal
- runtime path is not writable
- log or PID file location is too restrictive

#### Validation
- service account can access required path
- service starts cleanly
- logs no longer show permission errors

### Scenario 3: SELinux Denial After App Path Change

#### Symptom
Service starts incorrectly or application behavior fails even though Unix permissions look correct.

#### Triage
```bash
getenforce
ausearch -m avc -ts recent
restorecon -Rv /path/to/content
```

#### Common Causes
- content moved to nonstandard path
- file context not restored
- app behavior exceeds allowed type policy

#### Validation
- AVC denials stop appearing
- app behaves normally
- corrective action is documented

### Scenario 4: Service Is Active but Users Still Cannot Reach It

#### Symptom
`systemctl` shows active, but users still report outage.

#### Triage
```bash
systemctl status <service>
ss -tulpn
curl -I http://localhost
firewall-cmd --list-all
```

#### Common Causes
- firewall blocks traffic
- service bound only to localhost
- upstream dependency broken
- health path works locally but not remotely

#### Validation
- app responds locally and remotely as expected
- required ports are open
- logs show healthy requests

## Exception and Compliance Thinking
Sometimes the correct answer is not “disable the hardening.” It is:

- document the exact operational requirement
- define the security impact
- propose a narrow compensating control
- document an exception if required

Examples:
- allow a required service account path with tighter scoped permission rather than broad access
- allow one required port instead of opening a wide range
- restore correct SELinux context instead of disabling enforcement

## Minimum Evidence Checklist
For each hardening-related issue, capture:

- service status output
- key log lines
- denial evidence if present
- the corrective action
- post-fix validation output
- exception or compensating-control note if needed

## Quick Runbook
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
journalctl -xe
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
id <service-account>
```
'@
Write-Utf8File -Path (Join-Path $stigPath "troubleshooting.md") -Content $stigTroubleshooting

Write-Section "Upgrading Linux services"

$linuxServices = @'
# Service Management

## Purpose
This document is a practical Linux service troubleshooting guide for administrators supporting production or production-like environments.

## Why This Matters
When services fail, users feel it immediately. The difference between a calm operator and a guesser is having a repeatable method that moves from symptom to evidence to fix to validation.

## Core systemd Commands
```bash
systemctl status <service>
systemctl restart <service>
systemctl stop <service>
systemctl start <service>
systemctl enable <service>
systemctl disable <service>
systemctl is-active <service>
systemctl list-units --type=service
systemctl --failed
```

## First-Response Workflow

### 1. Confirm the Exact Service
Avoid assumptions. Identify the exact service unit name.

### 2. Check Current Status
```bash
systemctl status <service>
```

### 3. Check Recent Logs
```bash
journalctl -u <service> -n 100 --no-pager
journalctl -xe
```

### 4. Confirm Process and Port State
```bash
ps aux | grep <service>
ss -tulpn
```

### 5. Check Config Validity if Supported
Examples:
```bash
nginx -t
sshd -t
apachectl configtest
```

### 6. Check Dependencies
Examples:
- upstream DB reachable
- mount exists
- DNS resolves
- cert/key readable
- runtime directory writable

### 7. Restart Only After Evidence Is Gathered
Then validate real functionality, not just active state.

## Common Failure Categories

### Bad Configuration
Symptoms:
- immediate exit
- syntax errors in logs
- restart fails repeatedly

### Port Conflict
Symptoms:
- bind errors
- service exits right after start
- another process already holds the port

Commands:
```bash
ss -tulpn | grep :80
lsof -i :80
```

### Permission Problem
Symptoms:
- cannot read config
- cannot write log or PID file
- permission denied in logs

Commands:
```bash
ls -l /path/to/file
namei -l /path/to/file
```

### SELinux Issue
Symptoms:
- Unix permissions look fine
- service still fails
- AVC denials appear

Commands:
```bash
getenforce
ausearch -m avc -ts recent
```

### Missing Dependency
Symptoms:
- service starts partially
- health check fails
- service relies on network, mount, or another daemon

Commands:
```bash
ping <dependency>
systemctl list-dependencies <service>
mount
```

## Validation Pattern
After a fix, validate all relevant layers:

- service active
- expected process exists
- expected port is listening
- local request succeeds
- remote request succeeds if expected
- logs are clean
- monitoring returns to normal

Examples:
```bash
systemctl is-active <service>
ss -tulpn
curl -I http://localhost
journalctl -u <service> -n 20 --no-pager
```

## Example: NGINX Failure After Config Change
```bash
systemctl status nginx
journalctl -u nginx -n 50 --no-pager
nginx -t
ss -tulpn | grep :80
curl -I http://localhost
```

## Example: SSHD Failure After Hardening
```bash
systemctl status sshd
journalctl -u sshd -n 50 --no-pager
sshd -t
ss -tulpn | grep :22
firewall-cmd --list-all
```

## Operational Rules
- never restart first and think later
- capture evidence before changing things
- validate function, not just status
- document recurring failure patterns
- build reusable runbooks from real incidents

## Quick Runbook
```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
ss -tulpn
# config test if supported
systemctl restart <service>
curl -I http://localhost
journalctl -u <service> -n 20 --no-pager
```
'@
Write-Utf8File -Path (Join-Path $linuxPath "services.md") -Content $linuxServices

Write-Section "Upgrading Terraform fundamentals"

$tfFundamentals = @'
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
'@
Write-Utf8File -Path (Join-Path $tfPath "fundamentals.md") -Content $tfFundamentals

Write-Section "Upgrading Azure networking"

$azureNetworking = @'
# Azure Networking

## Purpose
This document provides a practical troubleshooting and validation guide for Azure networking as used by systems administrators supporting virtual machines and connected services.

## Why This Matters
Many “server problems” are really network path problems. Azure networking issues often come down to one of these layers:

- wrong VNet or subnet
- NSG rule mismatch
- route table behavior
- NIC or public IP assumptions
- app binding issue inside the VM

## Core Azure Networking Components

### Virtual Network (VNet)
Defines the address space and logical network boundary.

### Subnet
A segment inside a VNet where resources are placed.

### Network Security Group (NSG)
Controls inbound and outbound traffic using rules.

### Network Interface (NIC)
Connects a VM to the network.

### Public IP
Provides public reachability when intentionally assigned.

### Route Table
Controls traffic flow beyond default routing.

## First Questions to Ask
- What VNet is the VM in?
- What subnet is the VM in?
- Is there an NSG on the NIC, subnet, or both?
- Does the VM need public access?
- Is the application actually listening inside the guest?
- Is there a custom route table affecting traffic?

## Useful CLI Commands
```bash
az network vnet list -o table
az network vnet subnet list --resource-group MyRg --vnet-name MyVnet -o table
az network nsg list -o table
az network nic list -o table
az vm list -o table
```

## Practical Troubleshooting Workflow

### 1. Confirm the VM Is Running
If the VM itself is down, network troubleshooting is secondary.

```bash
az vm list -o table
```

### 2. Confirm the NIC and IP Assignment
Validate:
- NIC exists
- correct subnet
- expected private IP
- public IP only if intended

### 3. Review NSG Rules
Check whether the required port is actually allowed.

Questions:
- Is inbound allowed from the correct source?
- Is outbound blocked unexpectedly?
- Are you troubleshooting the NIC NSG, subnet NSG, or both?

### 4. Review Routing
If custom route tables exist, make sure traffic is not being redirected unexpectedly.

### 5. Validate Guest OS Listening State
Even if Azure is open, the service still must be listening.

Inside the VM:
```bash
ss -tulpn
firewall-cmd --list-all
curl -I http://localhost
```

### 6. Distinguish Azure Network Issue vs Guest Issue
A common mistake is blaming Azure for a service that is not actually listening or is blocked by the guest firewall.

## Common Failure Patterns

### NSG Blocks Expected Traffic
Symptoms:
- VM reachable internally but not from expected source
- health checks fail from outside
- service works locally

### Wrong Subnet or VNet
Symptoms:
- expected peers cannot reach the VM
- route assumptions are wrong
- DNS or dependency reachability fails

### Public Exposure Assumption Error
Symptoms:
- admin expects public access but no public IP exists
- public IP exists but should not

### Guest Service Not Listening
Symptoms:
- Azure path is open
- app still unavailable
- local checks show no bound port

### Guest Firewall Blocks Traffic
Symptoms:
- NSG looks correct
- port is listening
- guest OS firewall blocks access

## Validation Checklist
After a fix, validate:
- correct VNet and subnet
- correct NIC and IP configuration
- correct NSG rules
- expected route behavior
- service listening in guest
- intended local and remote path works

## Example Investigation Pattern
1. Check VM state
2. Check NIC and IP
3. Check NSGs
4. Check routing
5. Check guest OS listener
6. Check guest firewall
7. Validate actual application response

## Quick Runbook
```bash
az vm list -o table
az network nic list -o table
az network nsg list -o table
# inside VM
ss -tulpn
firewall-cmd --list-all
curl -I http://localhost
```
'@
Write-Utf8File -Path (Join-Path $azurePath "networking.md") -Content $azureNetworking

Write-Section "Upgrading vulnerability prioritization"

$vulnPrioritization = @'
# Prioritization

## Purpose
This document explains how to prioritize vulnerability findings based on actual operational risk, not just scanner severity.

## Why This Matters
A scanner may call many things “critical,” but the real order of work should consider:

- exposure
- asset criticality
- exploitability
- business impact
- patch availability
- operational risk of remediation

## Core Risk Factors

### Severity
CVSS matters, but it is not the only signal.

### Exposure
A vulnerable public-facing system is usually higher priority than the same issue on an isolated internal host.

### Asset Criticality
A mission-critical server or system supporting high-value operations deserves more attention than a low-impact utility box.

### Known Exploit Activity
If active exploitation or mature public exploit code exists, urgency rises.

### Compensating Controls
Firewalls, isolation, EDR, hardening, or disabled services may reduce immediate risk.

### Ease and Safety of Remediation
Some high-risk issues can be patched quickly; others need staged testing and rollback planning.

## Practical Priority Model

### Highest Priority
Typical characteristics:
- critical severity
- public-facing or broadly reachable
- known exploit exists
- high-value or mission-critical asset
- weak compensating controls

### High Priority
Typical characteristics:
- severe issue on important internal system
- moderate-to-high blast radius
- patch available
- exploit plausible even if not yet active in your environment

### Medium Priority
Typical characteristics:
- important issue but limited exposure
- strong segmentation or monitoring reduces risk
- patching can be scheduled in a controlled window

### Lower Priority
Typical characteristics:
- low exposure
- noncritical asset
- strong compensating controls
- low exploitability
- patch deferred safely with documentation

## Risk-Based Questions to Ask
- Is the affected host internet-facing?
- Is this system mission-critical?
- Is the vulnerable component actually installed and active?
- Is exploit activity known?
- Would exploitation produce real business damage?
- Do compensating controls reduce practical exposure?
- Is the remediation likely to break production?

## Example Comparisons

### Example 1
**Critical CVE on public web server with active exploit**
Priority: highest

Why:
- public exposure
- known exploit
- direct attack path
- likely business impact

### Example 2
**Critical CVE on internal admin server behind segmentation**
Priority: high, but maybe below Example 1

Why:
- severity high
- exposure narrower
- compensating controls may exist

### Example 3
**Medium CVE on low-value internal utility host**
Priority: medium or lower

Why:
- limited exposure
- low business criticality
- easier to schedule safely

### Example 4
**High CVE on mission-critical system where patch may break service**
Priority: still high, but execution must include rollback planning and staged validation

## Prioritization Workflow
1. Review scanner finding
2. Confirm affected asset and role
3. Confirm vulnerable component exists
4. Assess exposure
5. Assess business impact
6. Assess exploitability
7. Check compensating controls
8. Determine urgency
9. Assign patch or mitigation path
10. Document rationale

## What Good Prioritization Looks Like
Good prioritization is:
- explainable
- repeatable
- risk-based
- operationally aware

Bad prioritization is:
- blindly following scanner score
- ignoring business context
- patching low-value items while high-exposure items wait
- failing to consider production risk

## Evidence to Record
For each important prioritization decision, record:
- asset name and function
- exposure level
- severity
- exploit context
- compensating controls
- remediation urgency
- patch or mitigation decision

## Quick Priority Summary
Use this mental shortcut:

**Severity x Exposure x Criticality x Exploitability - Compensating Controls = Practical Priority**

## Quick Runbook
- confirm the asset role
- confirm the vulnerable component exists
- check exposure
- check exploit context
- weigh business impact
- decide urgency
- document the reason
'@
Write-Utf8File -Path (Join-Path $vulnPath "prioritization.md") -Content $vulnPrioritization

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\05-stig-hardening\troubleshooting.md",
    "docs\02-linux-admin\services.md",
    "docs\03-terraform\fundamentals.md",
    "docs\04-azure\networking.md",
    "docs\07-vulnerability-management\prioritization.md"
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
Write-Host "Validation passed. The next 5 portfolio docs were upgraded successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git add ."
Write-Host 'git commit -m "docs: upgrade next 5 portfolio docs for linux terraform azure stig and vuln mgmt"'
Write-Host "git push"
