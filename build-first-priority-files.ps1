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

    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8
}

Write-Section "Validating repository path"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repo path does not exist: $RepoPath"
}

$linuxPath     = Join-Path $RepoPath "docs\02-linux-admin"
$terraformPath = Join-Path $RepoPath "docs\03-terraform"
$stigPath      = Join-Path $RepoPath "docs\05-stig-hardening"

Ensure-Directory -Path $linuxPath
Ensure-Directory -Path $terraformPath
Ensure-Directory -Path $stigPath

Write-Section "Building Linux administration files"

$linuxReadme = @'
# 02 - Linux Administration

## Purpose
This section serves as a practical Linux administration field guide for day-to-day systems operations in a mixed enterprise environment.

## Operational Focus
- Service management
- Networking diagnostics
- Storage and filesystem administration
- Logging and troubleshooting
- Security controls
- Task automation

## Recommended Usage
Use these documents as a working admin handbook. Update them with commands, validation steps, and lessons learned from real environments.

## Files
- `core-commands.md`
- `services.md`
- `networking.md`
- `storage.md`
- `logging.md`
- `security.md`
- `automation.md`
'@

$linuxCore = @'
# Core Commands

## Purpose
Capture the Linux commands most useful for administration, troubleshooting, patching, and recovery work.

## Filesystem Navigation
```bash
pwd
ls -lah
cd /path/to/location
tree
find /etc -name "*.conf"
```

## Search and Text Processing
```bash
grep -R "listen" /etc
grep -i error /var/log/messages
awk '{print $1}'
sed -n '1,20p' /etc/ssh/sshd_config
```

## File Operations
```bash
cp source.txt backup.txt
mv oldname newname
rm -f temp.txt
mkdir -p /opt/app/logs
tar -czf backup.tar.gz /etc
```

## Permissions and Ownership
```bash
chmod 640 file.txt
chown root:root file.txt
ls -l
umask
```

## Process Inspection
```bash
ps aux
top
htop
pgrep sshd
kill -9 <pid>
```

## Package Management (RHEL)
```bash
dnf check-update
dnf update -y
dnf install vim -y
rpm -qa | sort
```

## Validation Checklist
- Confirm command output before making changes
- Document destructive commands before running them
- Verify package changes in logs after updates
'@

$linuxServices = @'
# Service Management

## Purpose
Document how to manage and troubleshoot services using `systemd`.

## Core Commands
```bash
systemctl status sshd
systemctl restart sshd
systemctl stop firewalld
systemctl start firewalld
systemctl enable chronyd
systemctl disable telnet.socket
systemctl list-units --type=service
systemctl --failed
```

## Failed Service Workflow
1. Check service state:
   ```bash
   systemctl status <service>
   ```
2. Review recent logs:
   ```bash
   journalctl -u <service> -n 100 --no-pager
   ```
3. Check full boot/session failures:
   ```bash
   journalctl -xe
   ```
4. Confirm config syntax if the service supports it
5. Restart the service
6. Re-check status and validate the port or application response

## Common Failure Causes
- Invalid configuration file
- Missing dependency
- Port already in use
- Permission denied
- SELinux blocking action
- Service account issue

## Validation
```bash
systemctl is-active <service>
ss -tulpn
curl -I http://localhost
```

## Example: NGINX Recovery
```bash
systemctl status nginx
journalctl -u nginx -n 50 --no-pager
nginx -t
systemctl restart nginx
ss -tulpn | grep :80
curl -I http://localhost
```
'@

$linuxNetworking = @'
# Networking

## Purpose
Provide a repeatable approach for diagnosing Linux connectivity issues.

## Interface and Address Checks
```bash
ip addr
ip link
nmcli device status
hostname -I
```

## Routing and DNS
```bash
ip route
cat /etc/resolv.conf
nslookup example.com
dig example.com
```

## Port and Socket Checks
```bash
ss -tulpn
ss -anp
netstat -tulpn
```

## Connectivity Tests
```bash
ping 8.8.8.8
ping google.com
curl -I https://example.com
traceroute google.com
```

## Firewall Checks
```bash
firewall-cmd --state
firewall-cmd --list-all
firewall-cmd --list-ports
```

## Troubleshooting Workflow
1. Confirm the interface is up
2. Confirm the IP address is correct
3. Confirm the route table is sane
4. Test raw IP connectivity
5. Test DNS resolution
6. Check local listening ports
7. Check firewall rules
8. Validate application response

## Validation
- Interface is up
- IP and route are correct
- DNS resolves
- Port is listening
- Application responds
'@

$linuxStorage = @'
# Storage

## Purpose
Document disk, filesystem, and LVM operations needed by a systems administrator.

## Disk and Filesystem Inventory
```bash
lsblk
blkid
df -h
du -sh /var/*
mount
cat /etc/fstab
```

## Disk Usage Troubleshooting
```bash
df -h
du -sh /*
find /var/log -type f -size +100M
find / -xdev -type f -size +500M 2>/dev/null
```

## LVM Commands
```bash
pvs
vgs
lvs
pvcreate /dev/sdb
vgcreate data_vg /dev/sdb
lvcreate -L 10G -n app_lv data_vg
mkfs.xfs /dev/data_vg/app_lv
mount /dev/data_vg/app_lv /mnt/app
```

## Expansion Example
```bash
lvextend -r -L +5G /dev/data_vg/app_lv
```

## Common Problems
- Filesystem full
- Log growth consuming space
- Mount missing after reboot
- Wrong fstab entry
- LVM not extended after disk growth

## Validation
```bash
df -h
mount | grep /mnt/app
lsblk
```
'@

$linuxLogging = @'
# Logging

## Purpose
Provide a practical log review workflow for service failures, upgrades, and security validation.

## Primary Log Tools
```bash
journalctl
tail -f /var/log/messages
tail -f /var/log/secure
dmesg
```

## journalctl Examples
```bash
journalctl -u sshd
journalctl -u nginx -n 50 --no-pager
journalctl --since "1 hour ago"
journalctl -p err -b
```

## Log Review Workflow
1. Identify the affected service or subsystem
2. Pull recent service logs
3. Review boot or kernel errors if needed
4. Check authentication logs for access failures
5. Correlate timestamps with user actions or patch events

## Useful Logs
- `/var/log/messages`
- `/var/log/secure`
- `/var/log/audit/audit.log`
- Application-specific log paths

## Validation
- Error source identified
- Event timeline documented
- Fix applied
- Healthy logs confirmed after change
'@

$linuxSecurity = @'
# Security

## Purpose
Track Linux security controls most relevant to admin work in enterprise and regulated environments.

## User and sudo Basics
```bash
id username
getent passwd username
sudo -l
visudo
```

## Permissions
```bash
ls -l
chmod 600 /path/to/file
chown root:root /path/to/file
```

## SSH Hardening Checks
```bash
cat /etc/ssh/sshd_config
sshd -t
systemctl restart sshd
```

## SELinux Basics
```bash
getenforce
sestatus
ausearch -m avc -ts recent
restorecon -Rv /var/www/html
```

## firewalld Basics
```bash
firewall-cmd --state
firewall-cmd --list-all
firewall-cmd --add-service=https --permanent
firewall-cmd --reload
```

## Common Security Failure Points
- SSH config breaks remote access
- Wrong file permissions stop service startup
- SELinux denies app behavior
- Firewall rule blocks application traffic
- Overly broad sudo access

## Validation
- Access works as intended
- Logs show no new denials
- Ports are reachable only as expected
- Permissions match policy
'@

$linuxAutomation = @'
# Automation

## Purpose
Document basic Linux automation patterns that save time and improve consistency.

## Bash Script Structure
```bash
#!/usr/bin/env bash
set -euo pipefail
```

## Common Use Cases
- Service health checks
- Disk usage reporting
- Package update checks
- Log collection
- Backup verification

## Example: Health Check Script
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

## Cron Basics
```bash
crontab -l
crontab -e
```

## Automation Rules
- Log all meaningful actions
- Fail safely
- Validate before changing production settings
- Prefer idempotent checks when possible

## Validation
- Script runs without syntax errors
- Output is readable
- Failure conditions are obvious
- Results are logged or visible
'@

Write-Utf8File -Path (Join-Path $linuxPath "README.md") -Content $linuxReadme
Write-Utf8File -Path (Join-Path $linuxPath "core-commands.md") -Content $linuxCore
Write-Utf8File -Path (Join-Path $linuxPath "services.md") -Content $linuxServices
Write-Utf8File -Path (Join-Path $linuxPath "networking.md") -Content $linuxNetworking
Write-Utf8File -Path (Join-Path $linuxPath "storage.md") -Content $linuxStorage
Write-Utf8File -Path (Join-Path $linuxPath "logging.md") -Content $linuxLogging
Write-Utf8File -Path (Join-Path $linuxPath "security.md") -Content $linuxSecurity
Write-Utf8File -Path (Join-Path $linuxPath "automation.md") -Content $linuxAutomation

Write-Section "Building Terraform files"

$terraformReadme = @'
# 03 - Terraform

## Purpose
This section provides a practical Terraform guide for infrastructure administration with emphasis on Azure deployment patterns and operational safety.

## Operational Focus
- Core Terraform concepts
- State management
- Reusable modules
- Azure deployment examples
- Troubleshooting failed plans and applies

## Recommended Usage
Use these docs to understand how infrastructure is declared, planned, deployed, validated, and maintained over time.
'@

$terraformFundamentals = @'
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
'@

$terraformState = @'
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
'@

$terraformModules = @'
# Modules

## Purpose
Explain how modules improve consistency and reuse in infrastructure code.

## Why Use Modules
Modules reduce duplication and standardize common resource patterns.

## Typical Module Elements
- `main.tf`
- `variables.tf`
- `outputs.tf`

## Example Use Cases
- Standard VM deployment
- Standard NSG pattern
- Reusable resource group layout
- Shared storage account configuration

## Benefits
- reuse
- consistency
- easier maintenance
- clearer review boundaries

## Validation
- module inputs are documented
- outputs are useful
- multiple deployments use the same standard pattern
'@

$terraformAzureExamples = @'
# Azure Examples

## Purpose
Provide small Azure deployment patterns that are easy to understand and validate.

## Resource Group Example
```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-sysadmin-field-guide"
  location = "East US"
}
```

## Virtual Network Example
```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-sysadmin-lab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}
```

## Subnet Example
```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
```

## Validation
- resources appear in Azure
- naming is consistent
- CIDR ranges are correct
- plan output matches intent
'@

$terraformTroubleshooting = @'
# Terraform Troubleshooting

## Purpose
Capture common Terraform failure modes and how to resolve them safely.

## Common Problems
- provider authentication failure
- syntax error
- invalid resource argument
- dependency order issue
- state lock problem
- drift between code and cloud

## Troubleshooting Workflow
1. Run:
   ```bash
   terraform fmt
   terraform validate
   terraform plan
   ```
2. Read the exact error
3. Check provider credentials
4. Check variable values
5. Check state health
6. Re-run plan before any apply

## Useful Commands
```bash
terraform validate
terraform plan
terraform state list
terraform providers
```

## Validation
- error reproduced and understood
- fix applied in code, not guessed
- plan runs cleanly
- apply succeeds only after plan is correct
'@

Write-Utf8File -Path (Join-Path $terraformPath "README.md") -Content $terraformReadme
Write-Utf8File -Path (Join-Path $terraformPath "fundamentals.md") -Content $terraformFundamentals
Write-Utf8File -Path (Join-Path $terraformPath "state-management.md") -Content $terraformState
Write-Utf8File -Path (Join-Path $terraformPath "modules.md") -Content $terraformModules
Write-Utf8File -Path (Join-Path $terraformPath "azure-examples.md") -Content $terraformAzureExamples
Write-Utf8File -Path (Join-Path $terraformPath "troubleshooting.md") -Content $terraformTroubleshooting

Write-Section "Building STIG hardening files"

$stigReadme = @'
# 05 - STIG Hardening

## Purpose
This section captures practical STIG hardening guidance for administrators working in secure and compliance-driven environments.

## Operational Focus
- What STIGs are
- Why systems break after hardening
- Common implementation issues
- Troubleshooting workflow
- Compliance validation and evidence

## Recommended Usage
Use this section as both a study guide and a troubleshooting reference when security baselines create operational problems.
'@

$stigWhat = @'
# What STIGs Are

## Purpose
Explain what STIGs are and why they matter in secure environments.

## Definition
STIG stands for **Security Technical Implementation Guide**. STIGs are detailed configuration baselines published to improve system security and reduce attack surface.

## Why They Matter
STIGs are used to:
- enforce security baselines
- reduce insecure defaults
- strengthen authentication and auditing
- standardize hardening expectations

## What They Usually Affect
- passwords and authentication
- SSH / remote access
- auditing and logging
- file permissions
- service configuration
- account policies
- network exposure

## Admin Reality
STIGs improve security, but they also create operational risk if applied without testing dependencies and service behavior.

## Validation
- baseline is understood before implementation
- affected systems and apps are identified
- change scope is documented
'@

$stigBreak = @'
# Why Systems Break After Hardening

## Purpose
Document why STIG implementation often creates outages or unexpected behavior.

## Common Reasons
1. **Permissions get tighter**
   - apps lose access to files, paths, or sockets

2. **Authentication rules change**
   - service accounts or remote automation stop working

3. **Services are disabled**
   - required but insecure-by-default services may be turned off

4. **SSH settings change**
   - root login, ciphers, or auth methods may be restricted

5. **Auditing increases overhead**
   - logging or auditing changes can affect performance or app behavior

6. **SELinux or firewall rules become stricter**
   - legitimate traffic or actions may be denied

## Operational Lesson
A secure baseline is not just a checkbox. It must be validated against the real workload.

## Validation
- each control change is understood
- dependencies were reviewed
- service behavior is tested after change
'@

$stigCommon = @'
# Common STIG Issues

## Purpose
Track the most frequent breakpoints seen after hardening.

## SSH Access Problems
- remote login fails
- root login blocked
- key-based auth misconfigured
- approved crypto settings break older clients

## Service Account Problems
- app runs under an account that no longer has required privileges
- scheduled jobs stop working
- automation scripts fail silently

## File Permission Problems
- app cannot read config file
- web service cannot write logs or temp files
- startup scripts fail due to restricted permissions

## Logging and Auditing Problems
- app fills disk with logs
- audit rules create noise
- required log paths are inaccessible

## Application Breakage
- daemon starts but app fails
- service appears active but endpoint is dead
- dependencies were not considered before hardening

## Validation
- failed behavior mapped to actual control changes
- log evidence captured
- service retested after fix
'@

$stigTroubleshooting = @'
# STIG Troubleshooting

## Purpose
Provide a repeatable workflow for diagnosing systems that broke after hardening.

## Workflow
1. Identify what changed
2. Confirm which service or function is broken
3. Review service state
4. Review logs
5. Compare new settings to previous baseline
6. Validate permissions, auth, SELinux, and firewall behavior
7. Apply the smallest safe corrective action
8. Re-test and document evidence

## Commands to Start With
```bash
systemctl status <service>
journalctl -xe
journalctl -u <service> -n 100 --no-pager
getenforce
ausearch -m avc -ts recent
firewall-cmd --list-all
ss -tulpn
ls -l /path/to/file
```

## Questions to Ask
- What exact STIG setting changed?
- Did remote access break or only app behavior?
- Did permissions change?
- Did the firewall change?
- Did authentication policy change?
- Did SELinux start blocking a valid action?

## Safe Fix Pattern
- confirm root cause
- apply minimal corrective change
- document why the change is needed
- preserve compliance where possible
- record any required exception

## Validation
- service starts cleanly
- logs are healthy
- access works as intended
- evidence is documented
'@

$stigCompliance = @'
# Compliance Workflow

## Purpose
Track the operational workflow for implementing and validating hardening changes.

## Workflow Stages
1. Prepare
2. Review baseline requirements
3. Identify affected systems and applications
4. Apply changes in a controlled sequence
5. Validate technical functionality
6. Validate security compliance
7. Record evidence
8. Track exceptions

## Evidence to Capture
- screenshots or config output
- command results
- service status
- scan results
- ticket references
- exception approvals

## Exception Handling
When a setting cannot be applied without breaking a mission-critical function:
- document the reason
- identify risk
- propose compensating controls
- obtain formal approval if required

## Validation
- baseline implemented or exception recorded
- system remains operational
- evidence supports audit review
'@

Write-Utf8File -Path (Join-Path $stigPath "README.md") -Content $stigReadme
Write-Utf8File -Path (Join-Path $stigPath "what-is-stig.md") -Content $stigWhat
Write-Utf8File -Path (Join-Path $stigPath "why-systems-break.md") -Content $stigBreak
Write-Utf8File -Path (Join-Path $stigPath "common-issues.md") -Content $stigCommon
Write-Utf8File -Path (Join-Path $stigPath "troubleshooting.md") -Content $stigTroubleshooting
Write-Utf8File -Path (Join-Path $stigPath "compliance-workflow.md") -Content $stigCompliance

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\02-linux-admin\README.md",
    "docs\02-linux-admin\core-commands.md",
    "docs\02-linux-admin\services.md",
    "docs\02-linux-admin\networking.md",
    "docs\02-linux-admin\storage.md",
    "docs\02-linux-admin\logging.md",
    "docs\02-linux-admin\security.md",
    "docs\02-linux-admin\automation.md",
    "docs\03-terraform\README.md",
    "docs\03-terraform\fundamentals.md",
    "docs\03-terraform\state-management.md",
    "docs\03-terraform\modules.md",
    "docs\03-terraform\azure-examples.md",
    "docs\03-terraform\troubleshooting.md",
    "docs\05-stig-hardening\README.md",
    "docs\05-stig-hardening\what-is-stig.md",
    "docs\05-stig-hardening\why-systems-break.md",
    "docs\05-stig-hardening\common-issues.md",
    "docs\05-stig-hardening\troubleshooting.md",
    "docs\05-stig-hardening\compliance-workflow.md"
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
Write-Host "Validation passed. All first-priority files were created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git add ."
Write-Host 'git commit -m "docs: build first priority linux terraform stig files"'
Write-Host "git push"
