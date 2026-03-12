<#
.SYNOPSIS
Upgrades the systems-engineer-field-guide repository to an elite portfolio-grade structure.

.DESCRIPTION
This script:
1. Validates that it is being run from the correct repository root.
2. Creates the elite folder structure.
3. Writes/updates a flagship README.
4. Generates architecture, runbook, incident, security, cloud, checklist, lab, Terraform, and script files.
5. Creates Mermaid and Draw.io placeholder diagram assets.
6. Validates that all expected files were created successfully.

.RECOMMENDED USAGE
cd "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\upgrade-repo-to-elite.ps1

Then:
git status
git add .
git commit -m "docs: upgrade repo to elite portfolio-grade field guide"
git push
#>

[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

function New-DirectoryIfMissing {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
    else {
        Write-Host "Directory already exists: $Path" -ForegroundColor DarkGray
    }
}

function Write-FileSafely {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ((Test-Path -LiteralPath $Path) -and -not $Force) {
        Write-Host "Skipped existing file (use -Force to overwrite): $Path" -ForegroundColor Yellow
        return
    }

    $Content | Set-Content -LiteralPath $Path -Encoding UTF8
    Write-Host "Wrote file: $Path" -ForegroundColor Green
}

function Assert-RepoRoot {
    param([string]$Root)

    $expectedItems = @(
        "README.md",
        "tools"
    )

    $missing = @()
    foreach ($item in $expectedItems) {
        $fullPath = Join-Path $Root $item
        if (-not (Test-Path -LiteralPath $fullPath)) {
            $missing += $item
        }
    }

    if ($missing.Count -gt 0) {
        throw "Repository validation failed. Missing expected items at repo root: $($missing -join ', ')"
    }

    $leaf = Split-Path $Root -Leaf
    if ($leaf -ne "systems-engineer-field-guide") {
        Write-Host "Warning: current folder name is '$leaf' instead of 'systems-engineer-field-guide'." -ForegroundColor Yellow
    }
}

function Test-ExpectedFiles {
    param([string[]]$Paths)

    $missing = @()
    foreach ($path in $Paths) {
        if (-not (Test-Path -LiteralPath $path)) {
            $missing += $path
        }
    }

    if ($missing.Count -gt 0) {
        throw "Validation failed. Missing expected files:`n - $($missing -join "`n - ")"
    }
}

$repoRoot = (Get-Location).Path

Write-Step "Validating repository path"
Assert-RepoRoot -Root $repoRoot

Write-Step "Creating elite folder structure"

$directories = @(
    "docs",
    "docs\architecture",
    "docs\runbooks",
    "docs\incidents",
    "docs\security",
    "docs\cloud",
    "docs\checklists",
    "terraform",
    "terraform\azure-linux-vm",
    "terraform\network",
    "scripts",
    "scripts\linux",
    "scripts\windows",
    "scripts\azure",
    "labs",
    "diagrams",
    "assets",
    "tools"
)

foreach ($dir in $directories) {
    New-DirectoryIfMissing -Path (Join-Path $repoRoot $dir)
}

Write-Step "Writing flagship README"

$readme = @'
# Systems Engineer Field Guide

A practical enterprise operations manual for managing secure infrastructure environments.

This repository contains operational runbooks, automation scripts, architecture documentation, and hands-on lab material for managing:

- Linux servers (RHEL / enterprise distributions)
- Windows Server environments
- Microsoft Azure cloud infrastructure
- Terraform infrastructure automation
- STIG hardened systems
- Vulnerability remediation workflows
- Monitoring and logging pipelines

The goal of this project is to provide a real-world reference guide for enterprise systems administration and infrastructure operations.

---

## Core Technologies

- Linux (RHEL / enterprise distributions)
- Windows Server
- Microsoft Azure
- Terraform
- PowerShell
- Bash
- Nessus Vulnerability Management
- DISA STIG Hardening

---

## Repository Structure

    docs/       Operational runbooks, architecture notes, incidents, security, and checklists
    terraform/  Infrastructure as code examples
    scripts/    Automation utilities for Linux, Windows, and Azure
    labs/       Hands-on practice scenarios
    diagrams/   Mermaid and Draw.io diagram source files
    assets/     Exported visuals and images used in documentation
    tools/      Repository maintenance and upgrade scripts

---

## Example Use Cases

This repository demonstrates operational procedures used in enterprise environments:

- performing server upgrades safely
- managing patch cycles
- troubleshooting infrastructure incidents
- automating infrastructure deployments
- validating security compliance
- responding to system failures

---

## Architecture Diagrams

### Infrastructure Overview

    flowchart TD
        U[Users / Administrators] --> LB[Load Balancer / Entry Point]
        LB --> L1[Linux Servers]
        LB --> W1[Windows Servers]
        LB --> A1[Azure Services]

### Monitoring Architecture

    flowchart TD
        S[Servers] --> LA[Log Agents]
        LA --> CL[Central Logging]
        CL --> M[Monitoring / SIEM]

### Patch Management Workflow

    flowchart TD
        VS[Vulnerability Scan] --> RP[Remediation Planning]
        RP --> TE[Testing Environment]
        TE --> PD[Production Deployment]
        PD --> VV[Validation Scan]

---

## Why This Repository Exists

Most infrastructure documentation is scattered across internal systems and team notes.

This project organizes real-world operational procedures into a single reference repository and demonstrates:

- enterprise systems administration practices
- infrastructure troubleshooting workflows
- automation techniques
- security compliance procedures
- operations documentation discipline

---

## Suggested Next Steps

- expand each runbook with screenshots and command output examples
- add Terraform modules for additional Azure resources
- export diagrams to PNG/SVG for portfolio polish
- add validation scripts and lab completion checklists
- connect incident playbooks to detection and logging workflows
'@

Write-FileSafely -Path (Join-Path $repoRoot "README.md") -Content $readme

Write-Step "Writing architecture documents"

$infrastructureOverview = @'
# Infrastructure Overview

## Purpose

This document describes a representative infrastructure model for enterprise systems administration across on-premises and cloud-connected environments.

## Core Components

- Linux servers supporting applications, automation tasks, and services
- Windows servers supporting directory, management, and enterprise workloads
- Azure services for cloud-hosted infrastructure and monitoring
- Centralized logging and monitoring to support operations and incident response
- Security controls aligned to STIG and vulnerability remediation workflows

## Administrative Priorities

1. Maintain system availability
2. Apply patches safely and consistently
3. Validate backups and rollback options
4. Maintain secure baselines
5. Document operational decisions and changes

## Example Platform Model

- Entry point: Load balancer or management access tier
- Compute: Linux and Windows server fleet
- Cloud: Azure-hosted services and virtual machines
- Logging: central pipeline for system and security events
- Security: STIG hardening, patching, scanning, and remediation
'@

$loggingArchitecture = @'
# Logging Architecture

## Objective

Provide a reliable path for collecting, transporting, and reviewing system and security logs.

## Logging Pipeline

1. Server or workload generates logs
2. Log collection agent forwards events
3. Logs are centralized in a storage or analytics platform
4. Monitoring and SIEM tooling alert on anomalies or failures

## Recommended Log Sources

- Linux system logs
- Windows Event Logs
- authentication events
- service failures
- patching activity
- audit logs
- Azure activity logs
- vulnerability scan summaries

## Validation Checklist

- confirm agent service is running
- confirm logs are being forwarded
- confirm timestamps are correct
- confirm log retention settings
- confirm critical events are searchable
'@

$monitoringArchitecture = @'
# Monitoring Architecture

## Goal

Enable proactive detection of system health, performance degradation, and service outages.

## Monitoring Domains

- CPU, memory, and disk utilization
- service availability
- failed logons and security alerts
- patching success/failure
- Azure VM health
- backup job success
- certificate expiration
- filesystem growth trends

## Escalation Model

- warning: investigate during business hours
- critical: immediate triage
- outage: incident workflow and service restoration process

## Operational Notes

Monitoring must be tied to actionable runbooks. Every alert should map to a clear troubleshooting path.
'@

Write-FileSafely -Path (Join-Path $repoRoot "docs\architecture\infrastructure-overview.md") -Content $infrastructureOverview
Write-FileSafely -Path (Join-Path $repoRoot "docs\architecture\logging-architecture.md") -Content $loggingArchitecture
Write-FileSafely -Path (Join-Path $repoRoot "docs\architecture\monitoring-architecture.md") -Content $monitoringArchitecture

Write-Step "Writing runbooks"

$linuxUpgrade = @'
# Linux Server Upgrade Runbook

## Pre-Upgrade Validation

### Identify platform version

    cat /etc/os-release
    uname -r

### Check uptime and current health

    uptime
    systemctl --failed
    journalctl -p 3 -xb

### Verify disk capacity

    df -h
    du -sh /var /usr /home

### Verify backup state

- confirm latest backup completed successfully
- confirm restore path is documented
- confirm rollback point exists if required

### Confirm maintenance window

- approved change ticket
- business owner approval
- support contacts notified

## Apply Updates

### Refresh metadata and apply patches

    sudo dnf check-update
    sudo dnf update -y

### Reboot if required

    sudo reboot

## Post-Upgrade Validation

### Confirm system returns successfully

    uptime
    systemctl --failed
    journalctl -p 3 -xb

### Validate critical services

    systemctl status sshd
    systemctl status firewalld

### Document outcome

- package changes applied
- reboot status
- service validation results
- issues or deviations
'@

$windowsUpgrade = @'
# Windows Server Upgrade Runbook

## Pre-Upgrade Validation

- confirm change approval
- confirm backup or snapshot
- verify free disk space
- record installed roles and running services
- identify reboot impact

## Health Checks

    Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber
    Get-Service | Where-Object {$_.Status -ne "Running" -and $_.StartType -eq "Automatic"}
    Get-Volume | Select-Object DriveLetter, SizeRemaining, Size

## Apply Updates

    Install-WindowsUpdate -AcceptAll -AutoReboot

## Post-Upgrade Validation

    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10
    Get-Service | Where-Object {$_.Status -ne "Running" -and $_.StartType -eq "Automatic"}
    Get-EventLog -LogName System -Newest 50

## Closeout

- confirm applications responded normally
- confirm monitoring restored
- document issues and remediation steps
'@

$patchManagement = @'
# Patch Management Runbook

## Objective

Apply patches in a controlled and validated way across Linux, Windows, and cloud-connected assets.

## Workflow

1. Review vulnerability and patch advisories
2. Identify affected assets
3. Test in lower environment where possible
4. Schedule maintenance window
5. Apply patches
6. Reboot and validate
7. Re-scan or re-check status
8. Document completion

## Minimum Validation

- services started successfully
- no critical errors in system logs
- monitoring is healthy
- disk and memory usage remain normal
- security controls still active

## Rollback Requirements

- snapshot, image, or backup available
- restore owner identified
- rollback decision criteria defined
'@

$backupVerification = @'
# Backup Verification Runbook

## Goal

Validate that backups are completing successfully and can support restore operations.

## Checklist

- confirm latest successful backup timestamp
- confirm backup includes critical system and data paths
- confirm retention policy is correct
- confirm restore testing has been performed
- confirm offsite or secondary location exists if required

## Linux Checks

    grep -i backup /var/log/messages

## Windows Checks

    Get-WinEvent -LogName Application | Where-Object {$_.Message -match "backup"} | Select-Object -First 20

## Validation Outcome

Document:
- backup date/time
- restore point or recovery identifier
- exceptions
- next test date
'@

$disasterRecovery = @'
# Disaster Recovery Runbook

## Objective

Provide a basic operational sequence for recovering a failed service or system.

## Initial Actions

1. identify outage scope
2. identify impacted systems and users
3. engage support contacts
4. determine whether restore, rebuild, or failover is required

## Data Points to Capture

- time of outage
- likely cause
- affected systems
- backup availability
- current service health
- business impact

## Recovery Paths

- restore from backup
- roll back recent change
- fail over to alternate system
- rebuild system from hardened baseline

## Post-Recovery

- validate application/service function
- monitor for recurrence
- document incident timeline
- create corrective actions
'@

Write-FileSafely -Path (Join-Path $repoRoot "docs\runbooks\linux-server-upgrade.md") -Content $linuxUpgrade
Write-FileSafely -Path (Join-Path $repoRoot "docs\runbooks\windows-server-upgrade.md") -Content $windowsUpgrade
Write-FileSafely -Path (Join-Path $repoRoot "docs\runbooks\patch-management.md") -Content $patchManagement
Write-FileSafely -Path (Join-Path $repoRoot "docs\runbooks\backup-verification.md") -Content $backupVerification
Write-FileSafely -Path (Join-Path $repoRoot "docs\runbooks\disaster-recovery.md") -Content $disasterRecovery

Write-Step "Writing incident playbooks"

$highCpu = @'
# High CPU Investigation

## Initial Triage

### Linux

    uptime
    top
    ps aux --sort=-%cpu | head
    journalctl -p 3 -xb

### Windows

    Get-Process | Sort-Object CPU -Descending | Select-Object -First 15
    Get-Counter '\Processor(_Total)\% Processor Time'

## Investigation Questions

- is the CPU spike sustained or transient?
- is a single process responsible?
- was there a recent deployment, patch, or config change?
- is the system under legitimate workload demand?

## Common Causes

- runaway process
- memory leak
- failed service restart loop
- scan or backup overload
- unexpected user/application demand

## Response Options

- restart offending service if approved
- scale resources if cloud-hosted and justified
- roll back recent change
- isolate workload for deeper investigation
'@

$diskFull = @'
# Disk Full Remediation

## Linux

    df -h
    du -xh / | sort -h | tail -n 20
    journalctl --disk-usage

## Windows

    Get-Volume | Sort-Object SizeRemaining
    Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 50

## Remediation Steps

- identify growth path
- remove temporary or stale files where approved
- rotate or archive logs
- extend storage if needed
- confirm application recovery after cleanup

## Prevention

- alert on filesystem thresholds
- review retention settings
- validate log rotation
'@

$serviceDown = @'
# Service Down Troubleshooting

## First Checks

- determine whether the outage is local or broad
- check monitoring alert details
- identify last known good time

## Linux

    systemctl status <service-name>
    journalctl -u <service-name> -n 100
    ss -tulpn

## Windows

    Get-Service -Name <service-name>
    Get-WinEvent -LogName System -MaxEvents 100
    netstat -ano

## Decision Tree

1. service not running -> attempt controlled restart
2. port not listening -> inspect config and dependencies
3. dependency failure -> restore dependency first
4. recurring failure -> collect logs and escalate
'@

$serverNotBooting = @'
# Server Not Booting

## Assessment

- physical or virtual?
- recent patch or config change?
- console access available?
- backup or snapshot available?

## Linux Recovery Ideas

- boot previous kernel if possible
- inspect emergency mode logs
- verify filesystem integrity
- check /etc/fstab issues
- validate boot partition usage

## Windows Recovery Ideas

- Startup Repair
- last known good recovery point
- Safe Mode diagnostics
- recent update rollback
- event log review from recovery environment if available

## Recovery Documentation

Record:
- boot symptom
- last known change
- chosen recovery path
- outcome
'@

Write-FileSafely -Path (Join-Path $repoRoot "docs\incidents\high-cpu-investigation.md") -Content $highCpu
Write-FileSafely -Path (Join-Path $repoRoot "docs\incidents\disk-full-remediation.md") -Content $diskFull
Write-FileSafely -Path (Join-Path $repoRoot "docs\incidents\service-down-troubleshooting.md") -Content $serviceDown
Write-FileSafely -Path (Join-Path $repoRoot "docs\incidents\server-not-booting.md") -Content $serverNotBooting

Write-Step "Writing security documentation"

$rhelStig = @'
# RHEL STIG Hardening

## Objectives

Apply and validate a secure baseline aligned with enterprise and DoD-style expectations.

## High-Level Controls

- disable direct root SSH login
- enforce password policy
- enable audit logging
- disable unused services
- validate firewall configuration
- restrict file permissions on sensitive files

## Example Checks

### SSH hardening

    sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config

### Audit rules

    sudo auditctl -l

### Sensitive permissions

    ls -l /etc/shadow
    ls -l /etc/ssh/sshd_config

## Notes

Document which controls are applied automatically, manually, or by baseline tooling.
'@

$windowsStig = @'
# Windows STIG Hardening

## Focus Areas

- password and account lockout policy
- local administrator control
- remote access restrictions
- audit policy
- Windows Defender and firewall state
- service and protocol hardening

## Example Validation

    secedit /export /cfg C:\temp\secpol.cfg
    Get-NetFirewallProfile
    AuditPol /get /category:*

## Documentation Expectations

- baseline used
- exceptions approved
- validation date
- remediation items remaining
'@

$vulnRemediation = @'
# Vulnerability Remediation Workflow

## Workflow

1. ingest scan results
2. validate finding accuracy
3. prioritize by severity, exploitability, and exposure
4. assign remediation owner
5. apply fix or mitigation
6. validate closure
7. document evidence

## Evidence Examples

- patched package version
- configuration screenshot or command output
- rescan result
- exception approval reference if not remediated
'@

$nessusWorkflow = @'
# Nessus Workflow

## Purpose

Provide a lightweight process for working scan results into an operational remediation cycle.

## Steps

1. review latest scan scope
2. identify critical and high findings
3. map findings to system owner
4. determine patch, config change, or compensating control
5. implement remediation
6. rerun scan or validate manually
7. close or document exception

## Tracking Fields

- asset
- plugin ID
- severity
- title
- remediation owner
- due date
- status
- validation result
'@

Write-FileSafely -Path (Join-Path $repoRoot "docs\security\rhel-stig-hardening.md") -Content $rhelStig
Write-FileSafely -Path (Join-Path $repoRoot "docs\security\windows-stig-hardening.md") -Content $windowsStig
Write-FileSafely -Path (Join-Path $repoRoot "docs\security\vulnerability-remediation.md") -Content $vulnRemediation
Write-FileSafely -Path (Join-Path $repoRoot "docs\security\nessus-workflow.md") -Content $nessusWorkflow

Write-Step "Writing cloud documentation"

$azureMonitoring = @'
# Azure Monitoring

## Objective

Monitor Azure-hosted assets for health, performance, and security-relevant events.

## Focus Areas

- VM availability
- activity logs
- resource health
- disk and CPU metrics
- backup and recovery status
- alert routing and ownership

## Operational Checklist

- confirm VM insights or equivalent telemetry is enabled
- confirm alert thresholds are meaningful
- confirm action groups route correctly
- confirm noisy alerts are tuned
'@

$azureVmManagement = @'
# Azure VM Management

## Core Tasks

- start / stop / restart virtual machines
- review status and health
- validate networking and NSG alignment
- monitor disk and performance metrics
- confirm backup protection status

## Example Azure PowerShell Commands

    Get-AzVM -Status
    Start-AzVM -ResourceGroupName "<rg>" -Name "<vm>"
    Stop-AzVM -ResourceGroupName "<rg>" -Name "<vm>" -Force
    Restart-AzVM -ResourceGroupName "<rg>" -Name "<vm>"
'@

$terraformDeployment = @'
# Terraform Deployment

## Goal

Use infrastructure as code to deploy predictable and reviewable Azure resources.

## Workflow

1. initialize provider plugins
2. validate syntax
3. review plan
4. apply approved changes
5. capture outputs
6. document deployed resources

## Commands

    terraform init
    terraform fmt -recursive
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan

## Guardrails

- never apply unreviewed production changes
- commit code before apply
- store state securely
- document variable inputs and outputs
'@

Write-FileSafely -Path (Join-Path $repoRoot "docs\cloud\azure-monitoring.md") -Content $azureMonitoring
Write-FileSafely -Path (Join-Path $repoRoot "docs\cloud\azure-vm-management.md") -Content $azureVmManagement
Write-FileSafely -Path (Join-Path $repoRoot "docs\cloud\terraform-deployment.md") -Content $terraformDeployment

Write-Step "Writing operational checklists"

$newServerBuild = @'
# New Server Build Checklist

- confirm system purpose and owner
- assign hostname and IP/DNS plan
- build from approved image or baseline
- apply latest approved updates
- configure monitoring
- configure logging
- apply security baseline
- validate backups
- document access and dependencies
'@

$patchTuesdayChecklist = @'
# Patch Tuesday Checklist

- review applicable Microsoft updates
- identify impacted systems
- confirm change window
- validate backups
- apply updates in approved order
- reboot where required
- validate services and logs
- document results and exceptions
'@

$serverUpgradeChecklist = @'
# Server Upgrade Checklist

- change approved
- maintenance window confirmed
- backups verified
- rollback plan documented
- dependencies identified
- health baseline captured
- upgrades applied
- reboot validated
- monitoring restored
- closeout documented
'@

$preUpgradeValidation = @'
# Pre-Upgrade Validation Checklist

## General

- confirm current version
- confirm free disk space
- confirm backup/snapshot
- confirm service owner approval
- confirm maintenance window
- confirm rollback path
- capture current health state
- capture running services/processes
'@

Write-FileSafely -Path (Join-Path $repoRoot "docs\checklists\new-server-build.md") -Content $newServerBuild
Write-FileSafely -Path (Join-Path $repoRoot "docs\checklists\patch-tuesday-checklist.md") -Content $patchTuesdayChecklist
Write-FileSafely -Path (Join-Path $repoRoot "docs\checklists\server-upgrade-checklist.md") -Content $serverUpgradeChecklist
Write-FileSafely -Path (Join-Path $repoRoot "docs\checklists\pre-upgrade-validation.md") -Content $preUpgradeValidation

Write-Step "Writing labs"

$linuxHardeningLab = @'
# Linux Hardening Lab

## Scenario

You are given a new RHEL server and must prepare it for production.

## Tasks

- review current packages and running services
- apply updates
- confirm firewall state
- enable or review audit logging
- harden SSH configuration
- validate permissions on sensitive files
- record your before/after findings

## Deliverables

- command log
- findings summary
- remediation list
'@

$terraformLab = @'
# Terraform Deploy Lab

## Objective

Deploy a basic Azure Linux VM using Terraform and document the workflow.

## Tasks

- initialize Terraform
- validate configuration
- review plan output
- apply infrastructure
- capture resource names and outputs
- destroy lab resources when complete

## Evidence

- terraform plan output
- terraform apply summary
- screenshot or text capture of Azure resources
'@

$azureMonitoringLab = @'
# Azure Monitoring Lab

## Objective

Practice reviewing the health of an Azure VM and basic monitoring data.

## Tasks

- locate VM status
- review CPU and disk metrics
- inspect activity log
- validate whether alerting is configured
- document what additional monitoring is needed
'@

$patchManagementLab = @'
# Patch Management Lab

## Objective

Walk through a patching cycle in a safe practice environment.

## Tasks

- identify available updates
- document current system health
- apply updates
- reboot if needed
- validate services, logs, and monitoring
- document change results
'@

Write-FileSafely -Path (Join-Path $repoRoot "labs\linux-hardening-lab.md") -Content $linuxHardeningLab
Write-FileSafely -Path (Join-Path $repoRoot "labs\terraform-deploy-lab.md") -Content $terraformLab
Write-FileSafely -Path (Join-Path $repoRoot "labs\azure-monitoring-lab.md") -Content $azureMonitoringLab
Write-FileSafely -Path (Join-Path $repoRoot "labs\patch-management-lab.md") -Content $patchManagementLab

Write-Step "Writing Terraform examples"

$tfMain = @'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "${var.name_prefix}-pip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "example" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_network_interface" "example" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_linux_virtual_machine" "example" {
  name                            = "${var.name_prefix}-vm01"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.example.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9-lvm"
    version   = "latest"
  }
}
'@

$tfVariables = @'
variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "rg-sysadmin-field-guide-lab"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "East US"
}

variable "name_prefix" {
  description = "Prefix used for resource naming."
  type        = string
  default     = "safg"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access."
  type        = string
}
'@

$tfOutputs = @'
output "resource_group_name" {
  value = azurerm_resource_group.example.name
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.example.name
}

output "public_ip" {
  value = azurerm_public_ip.example.ip_address
}
'@

$tfVnet = @'
# Placeholder network file for future expansion.
# Consolidated network resources currently live in ../azure-linux-vm/main.tf
'@

$tfSubnet = @'
# Placeholder subnet file for future expansion.
# Consolidated subnet resources currently live in ../azure-linux-vm/main.tf
'@

Write-FileSafely -Path (Join-Path $repoRoot "terraform\azure-linux-vm\main.tf") -Content $tfMain
Write-FileSafely -Path (Join-Path $repoRoot "terraform\azure-linux-vm\variables.tf") -Content $tfVariables
Write-FileSafely -Path (Join-Path $repoRoot "terraform\azure-linux-vm\outputs.tf") -Content $tfOutputs
Write-FileSafely -Path (Join-Path $repoRoot "terraform\network\vnet.tf") -Content $tfVnet
Write-FileSafely -Path (Join-Path $repoRoot "terraform\network\subnet.tf") -Content $tfSubnet

Write-Step "Writing automation scripts"

$linuxHealth = @'
#!/usr/bin/env bash
set -euo pipefail

echo "Server Health Check"
echo "==================="
echo

echo "[Uptime]"
uptime
echo

echo "[Disk Usage]"
df -h
echo

echo "[Memory Usage]"
free -m || true
echo

echo "[Failed Services]"
systemctl --failed || true
echo

echo "[Recent Critical Logs]"
journalctl -p 3 -xb -n 50 || true
'@

$linuxPatchCheck = @'
#!/usr/bin/env bash
set -euo pipefail

echo "Patch Check"
echo "==========="

if command -v dnf >/dev/null 2>&1; then
    dnf check-update || true
elif command -v yum >/dev/null 2>&1; then
    yum check-update || true
else
    echo "No supported package manager detected."
fi
'@

$diskUsageAlert = @'
#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="${1:-85}"

echo "Checking filesystems above ${THRESHOLD}% utilization..."
df -hP | awk -v threshold="$THRESHOLD" 'NR>1 {
    gsub(/%/,"",$5);
    if ($5+0 >= threshold) {
        print "ALERT:", $6, "is at", $5 "% used"
    }
}'
'@

$windowsHealth = @'
Write-Host "Windows System Health" -ForegroundColor Cyan
Write-Host "====================="

Write-Host "`n[Computer Info]" -ForegroundColor Yellow
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber

Write-Host "`n[Volumes]" -ForegroundColor Yellow
Get-Volume | Select-Object DriveLetter, FileSystemLabel, SizeRemaining, Size

Write-Host "`n[Automatic Services Not Running]" -ForegroundColor Yellow
Get-Service | Where-Object { $_.StartType -eq "Automatic" -and $_.Status -ne "Running" } |
    Select-Object Name, DisplayName, Status, StartType

Write-Host "`n[Recent System Events]" -ForegroundColor Yellow
Get-WinEvent -LogName System -MaxEvents 25 |
    Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message
'@

$patchStatus = @'
Write-Host "Windows Patch Status" -ForegroundColor Cyan
Write-Host "===================="

Get-HotFix |
    Sort-Object InstalledOn -Descending |
    Select-Object -First 20 Description, HotFixID, InstalledBy, InstalledOn
'@

$azureVmStatus = @'
param(
    [string]$ResourceGroupName = "",
    [string]$Name = ""
)

if (-not (Get-Module -ListAvailable -Name Az.Compute)) {
    Write-Error "Az.Compute module is not installed."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($ResourceGroupName) -or [string]::IsNullOrWhiteSpace($Name)) {
    Write-Host "Usage: .\vm-status.ps1 -ResourceGroupName <rg> -Name <vm>" -ForegroundColor Yellow
    exit 1
}

Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -Status |
    Select-Object Name, ResourceGroupName, Location,
        @{Name="PowerState";Expression={$_.Statuses | Where-Object {$_.Code -like "PowerState/*"} | Select-Object -ExpandProperty DisplayStatus}},
        @{Name="ProvisioningState";Expression={$_.Statuses | Where-Object {$_.Code -like "ProvisioningState/*"} | Select-Object -ExpandProperty DisplayStatus}}
'@

Write-FileSafely -Path (Join-Path $repoRoot "scripts\linux\server-health-check.sh") -Content $linuxHealth
Write-FileSafely -Path (Join-Path $repoRoot "scripts\linux\patch-check.sh") -Content $linuxPatchCheck
Write-FileSafely -Path (Join-Path $repoRoot "scripts\linux\disk-usage-alert.sh") -Content $diskUsageAlert
Write-FileSafely -Path (Join-Path $repoRoot "scripts\windows\system-health.ps1") -Content $windowsHealth
Write-FileSafely -Path (Join-Path $repoRoot "scripts\windows\patch-status.ps1") -Content $patchStatus
Write-FileSafely -Path (Join-Path $repoRoot "scripts\azure\vm-status.ps1") -Content $azureVmStatus

Write-Step "Writing diagram source files"

$infrastructureMermaid = @'
flowchart TD
    U[Users / Administrators] --> LB[Load Balancer / Entry Point]
    LB --> L[Linux Servers]
    LB --> W[Windows Servers]
    LB --> A[Azure Services]
'@

$monitoringMermaid = @'
flowchart TD
    S[Servers] --> LA[Log Agents]
    LA --> CL[Central Logging]
    CL --> SIEM[Monitoring / SIEM]
'@

$patchWorkflowMermaid = @'
flowchart TD
    VS[Vulnerability Scan] --> RP[Remediation Planning]
    RP --> TE[Testing Environment]
    TE --> PD[Production Deployment]
    PD --> VV[Validation Scan]
'@

$drawioPlaceholder = @'
<mxfile host="app.diagrams.net">
  <diagram id="placeholder" name="Page-1">
    <mxGraphModel dx="1184" dy="674" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <mxCell id="2" value="Replace this placeholder with a Draw.io diagram export." style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1">
          <mxGeometry x="180" y="140" width="360" height="100" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
'@

Write-FileSafely -Path (Join-Path $repoRoot "diagrams\infrastructure.mmd") -Content $infrastructureMermaid
Write-FileSafely -Path (Join-Path $repoRoot "diagrams\monitoring.mmd") -Content $monitoringMermaid
Write-FileSafely -Path (Join-Path $repoRoot "diagrams\patch-workflow.mmd") -Content $patchWorkflowMermaid
Write-FileSafely -Path (Join-Path $repoRoot "diagrams\infrastructure.drawio") -Content $drawioPlaceholder
Write-FileSafely -Path (Join-Path $repoRoot "diagrams\monitoring.drawio") -Content $drawioPlaceholder
Write-FileSafely -Path (Join-Path $repoRoot "diagrams\patch-workflow.drawio") -Content $drawioPlaceholder

Write-Step "Writing asset placeholders"

$architecturePngPlaceholder = @'
This file is a placeholder.
Export diagrams/infrastructure.drawio or diagrams/infrastructure.mmd to PNG and replace this file.
'@

$monitoringPngPlaceholder = @'
This file is a placeholder.
Export diagrams/monitoring.drawio or diagrams/monitoring.mmd to PNG and replace this file.
'@

Write-FileSafely -Path (Join-Path $repoRoot "assets\architecture.png.txt") -Content $architecturePngPlaceholder
Write-FileSafely -Path (Join-Path $repoRoot "assets\monitoring.png.txt") -Content $monitoringPngPlaceholder

Write-Step "Validating generated files"

$expectedFiles = @(
    "README.md",
    "docs\architecture\infrastructure-overview.md",
    "docs\architecture\logging-architecture.md",
    "docs\architecture\monitoring-architecture.md",
    "docs\runbooks\linux-server-upgrade.md",
    "docs\runbooks\windows-server-upgrade.md",
    "docs\runbooks\patch-management.md",
    "docs\runbooks\backup-verification.md",
    "docs\runbooks\disaster-recovery.md",
    "docs\incidents\high-cpu-investigation.md",
    "docs\incidents\disk-full-remediation.md",
    "docs\incidents\service-down-troubleshooting.md",
    "docs\incidents\server-not-booting.md",
    "docs\security\rhel-stig-hardening.md",
    "docs\security\windows-stig-hardening.md",
    "docs\security\vulnerability-remediation.md",
    "docs\security\nessus-workflow.md",
    "docs\cloud\azure-monitoring.md",
    "docs\cloud\azure-vm-management.md",
    "docs\cloud\terraform-deployment.md",
    "docs\checklists\new-server-build.md",
    "docs\checklists\patch-tuesday-checklist.md",
    "docs\checklists\server-upgrade-checklist.md",
    "docs\checklists\pre-upgrade-validation.md",
    "labs\linux-hardening-lab.md",
    "labs\terraform-deploy-lab.md",
    "labs\azure-monitoring-lab.md",
    "labs\patch-management-lab.md",
    "terraform\azure-linux-vm\main.tf",
    "terraform\azure-linux-vm\variables.tf",
    "terraform\azure-linux-vm\outputs.tf",
    "terraform\network\vnet.tf",
    "terraform\network\subnet.tf",
    "scripts\linux\server-health-check.sh",
    "scripts\linux\patch-check.sh",
    "scripts\linux\disk-usage-alert.sh",
    "scripts\windows\system-health.ps1",
    "scripts\windows\patch-status.ps1",
    "scripts\azure\vm-status.ps1",
    "diagrams\infrastructure.mmd",
    "diagrams\monitoring.mmd",
    "diagrams\patch-workflow.mmd",
    "diagrams\infrastructure.drawio",
    "diagrams\monitoring.drawio",
    "diagrams\patch-workflow.drawio",
    "assets\architecture.png.txt",
    "assets\monitoring.png.txt"
) | ForEach-Object { Join-Path $repoRoot $_ }

Test-ExpectedFiles -Paths $expectedFiles

Write-Step "Summary"
Write-Host "Elite repo upgrade completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "If you want to overwrite any skipped existing files, rerun with:" -ForegroundColor Yellow
Write-Host ".\tools\upgrade-repo-to-elite.ps1 -Force"
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Cyan
Write-Host "git status"
Write-Host "git add ."
Write-Host 'git commit -m "docs: upgrade repo to elite portfolio-grade field guide"'
Write-Host "git push"
