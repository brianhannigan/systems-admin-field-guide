param(
    [string]$RepoPath = "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide",
    [string]$RepoName = "systems-engineer-field-guide",
    [string]$AuthorName = "Brian Hannigan",
    [string]$GitHubUser = "brianhannigan",
    [switch]$InitializeGit
)

$ErrorActionPreference = "Stop"

function New-DirSafe {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function New-FileSafe {
    param(
        [string]$Path,
        [string]$Content
    )
    $parent = Split-Path $Path -Parent
    if ($parent) { New-DirSafe -Path $parent }
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function New-MarkdownSectionFile {
    param(
        [string]$Path,
        [string]$Title,
        [string[]]$Sections,
        [string]$Purpose = ""
    )

    $body = @"
# $Title

## Purpose
$Purpose

## Scope
- Define what this component covers
- Identify operational responsibilities
- Capture common risks, failure points, and validation steps

## Recommended Outcome
- Clear field guide content
- Practical commands or workflows
- Troubleshooting guidance
- Validation checklist

"@

    foreach ($section in $Sections) {
        $body += @"

## $section
- Add real-world notes here
- Add commands, workflows, or examples
- Add validation or troubleshooting notes

"@
    }

    New-FileSafe -Path $Path -Content $body
}

Write-Host "Building repo scaffold at: $RepoPath" -ForegroundColor Cyan
New-DirSafe -Path $RepoPath

# ----------------------------
# Root folders
# ----------------------------
$folders = @(
    ".github\ISSUE_TEMPLATE",
    "docs",
    "docs\01-first-30-days",
    "docs\02-linux-admin",
    "docs\03-terraform",
    "docs\04-azure",
    "docs\05-stig-hardening",
    "docs\06-server-upgrades",
    "docs\07-vulnerability-management",
    "docs\08-12-week-plan",
    "docs\09-cyber-range-labs",
    "docs\10-scripts",
    "docs\11-daily-practice",
    "docs\12-six-month-roadmap",
    "labs",
    "labs\linux",
    "labs\azure",
    "labs\terraform",
    "labs\stig",
    "scripts",
    "scripts\bash",
    "scripts\powershell",
    "scripts\terraform",
    "scripts\azure-cli",
    "diagrams",
    "diagrams\infrastructure",
    "diagrams\workflows",
    "diagrams\security",
    "assets"
)

foreach ($folder in $folders) {
    New-DirSafe -Path (Join-Path $RepoPath $folder)
}

# ----------------------------
# README
# ----------------------------
$readme = @"
# Systems Engineer First 90 Days Field Guide

A portfolio-grade systems administration operations guide focused on:

- Red Hat Linux administration
- Windows and Linux mixed infrastructure support
- Azure infrastructure operations
- Terraform infrastructure as code
- STIG hardening and compliance
- Server upgrades and patching
- Vulnerability remediation
- Single-VM cyber range practice labs

## Why this project exists

This repository was created as a structured operational training system for a new Systems Engineer role in a mixed enterprise environment. The goal is to provide a practical, field-ready knowledge base that can be expanded over time into a real operational handbook.

## Who this is for

- Systems Engineers
- Infrastructure Engineers
- DevOps / Platform Engineers
- Security-minded administrators
- Professionals supporting regulated or compliance-driven environments

## Repository map

- `/docs` â†’ field guide chapters
- `/labs` â†’ hands-on single-VM exercises
- `/scripts` â†’ admin automation examples
- `/diagrams` â†’ architecture and workflow visuals
- `/assets` â†’ images, banners, screenshots

## Core focus areas

- Linux troubleshooting
- Terraform learning path
- Azure administration
- STIG troubleshooting
- Patch / upgrade workflows
- Vulnerability management
- Practical single-VM training

## Suggested development order

1. STIG hardening
2. Linux administration
3. Terraform
4. Azure
5. Vulnerability management
6. Labs and scripts
7. Visual diagrams and repo polish

## Roadmap

See:
- [ROADMAP.md](ROADMAP.md)
- [PROJECT_BOARD.md](PROJECT_BOARD.md)
- [docs/MASTER_OUTLINE.md](docs/MASTER_OUTLINE.md)

## Status

This repository is being developed as an operations-focused infrastructure learning and portfolio project.

## Author

$AuthorName
GitHub: https://github.com/$GitHubUser
"@
New-FileSafe -Path (Join-Path $RepoPath "README.md") -Content $readme

# ----------------------------
# LICENSE
# ----------------------------
$license = @"
MIT License

Copyright (c) $(Get-Date -Format yyyy) $AuthorName

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the ""Software""), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
New-FileSafe -Path (Join-Path $RepoPath "LICENSE") -Content $license

# ----------------------------
# gitignore
# ----------------------------
$gitignore = @"
# OS / editor
.DS_Store
Thumbs.db
*.tmp
*.bak
*.swp
.vscode/
.idea/

# Python
__pycache__/
*.pyc

# Terraform
*.tfstate
*.tfstate.*
.terraform/
crash.log

# PowerShell logs or output
*.log

# Images / exports
*.pdf
*.zip
"@
New-FileSafe -Path (Join-Path $RepoPath ".gitignore") -Content $gitignore

# ----------------------------
# Roadmap / Project board / Contributing
# ----------------------------
$roadmap = @"
# Roadmap

## Milestone 1 - Repo Foundation
- [ ] Finalize repo structure
- [ ] Improve README
- [ ] Add issue templates
- [ ] Add master outline
- [ ] Add starter chapter files

## Milestone 2 - Core Operations Content
- [ ] Linux admin chapter
- [ ] Terraform fundamentals
- [ ] Azure infrastructure chapter
- [ ] Server upgrade strategy
- [ ] Vulnerability management workflow

## Milestone 3 - Security and Compliance
- [ ] STIG introduction
- [ ] Why systems break after hardening
- [ ] STIG troubleshooting workflow
- [ ] Compliance validation checklist

## Milestone 4 - Labs and Scripts
- [ ] Linux baseline lab
- [ ] Service outage lab
- [ ] Disk pressure lab
- [ ] Terraform workflow lab
- [ ] STIG validation lab
- [ ] Bash and PowerShell examples
- [ ] Azure CLI examples

## Milestone 5 - Portfolio Polish
- [ ] Mermaid diagrams
- [ ] Assets and screenshots
- [ ] Repo badges
- [ ] Navigation cleanup
- [ ] Interview-ready polish
"@
New-FileSafe -Path (Join-Path $RepoPath "ROADMAP.md") -Content $roadmap

$projectBoard = @"
# Project Board

## Backlog
- Create Linux core commands guide
- Create Linux services guide
- Create Linux networking guide
- Create Terraform fundamentals chapter
- Create Terraform state management chapter
- Create Azure VM deployment chapter
- Create Azure networking chapter
- Create STIG troubleshooting chapter
- Create vulnerability prioritization workflow
- Create patch validation checklist
- Create cyber range lab series
- Create scripts and examples
- Add diagrams

## In Progress
- Repo foundation
- README and documentation scaffold

## Review
- Move completed docs here for final polish review

## Done
- Initial repo structure created
"@
New-FileSafe -Path (Join-Path $RepoPath "PROJECT_BOARD.md") -Content $projectBoard

$contributing = @"
# Contributing

## Writing rules
- Prefer practical, field-ready content
- Use clear headings
- Include commands where relevant
- Include validation steps
- Include troubleshooting notes
- Avoid filler content
- Focus on operational usefulness

## Recommended chapter structure
1. Purpose
2. Scope
3. Key concepts
4. Commands / workflows
5. Common failure points
6. Validation checklist
7. Follow-up references

## Commit style
- docs: add linux services outline
- docs: add terraform state management chapter
- labs: add service outage lab
- scripts: add bash health check
- readme: improve project overview
"@
New-FileSafe -Path (Join-Path $RepoPath "CONTRIBUTING.md") -Content $contributing

# ----------------------------
# Master outline
# ----------------------------
$masterOutline = @"
# Master Outline

## 01 - First 30 Days
- Infrastructure discovery
- Questions to ask
- Red flags
- Documentation checklist

## 02 - Linux Administration
- Core commands
- Services
- Networking
- Storage
- Logging
- Security
- Automation

## 03 - Terraform
- Fundamentals
- State management
- Modules
- Azure examples
- Troubleshooting

## 04 - Azure
- VM deployment
- Networking
- IAM / RBAC
- Monitoring
- Security controls

## 05 - STIG Hardening
- What STIGs are
- Why systems break
- Common issues
- Troubleshooting
- Compliance workflow

## 06 - Server Upgrades
- Pre-upgrade checklist
- Snapshot strategy
- Rollback planning
- Testing strategy
- Post-upgrade validation

## 07 - Vulnerability Management
- Scan analysis
- Prioritization
- Patch workflow
- Validation

## 08 - 12 Week Plan
- Weeks 1-4
- Weeks 5-8
- Weeks 9-12

## 09 - Cyber Range Labs
- Linux baseline
- Service failure
- Disk pressure
- Patching
- STIG hardening
- Terraform workflow

## 10 - Scripts
- Bash
- PowerShell
- Terraform
- Azure CLI
- Troubleshooting helpers

## 11 - Daily Practice
- 30-minute routine

## 12 - Six Month Roadmap
- Team expert checklist
"@
New-FileSafe -Path (Join-Path $RepoPath "docs\MASTER_OUTLINE.md") -Content $masterOutline

# ----------------------------
# Chapter README files and starter docs
# ----------------------------

# 01
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\01-first-30-days\README.md") -Title "01 - First 30 Days Survival Plan" -Purpose "Capture the operational approach for surviving and learning the first month in a new systems administration role." -Sections @(
    "Infrastructure Discovery",
    "Questions to Ask",
    "Systems to Map",
    "Documentation to Collect",
    "Red Flags to Watch For"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\01-first-30-days\infrastructure-discovery.md") -Title "Infrastructure Discovery" -Purpose "Map the environment quickly and accurately." -Sections @("Inventory Strategy","Critical Systems","Dependencies","Monitoring","Access")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\01-first-30-days\questions-to-ask.md") -Title "Questions to Ask" -Purpose "Capture the most important discovery questions for inherited environments." -Sections @("Operations","Security","Upgrades","Patching","Ownership")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\01-first-30-days\red-flags.md") -Title "Red Flags" -Purpose "Track warning signs in inherited infrastructure." -Sections @("Documentation Gaps","Unsupported Systems","Single Points of Failure","Security Risks","Operational Risks")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\01-first-30-days\documentation-checklist.md") -Title "Documentation Checklist" -Purpose "List the docs that should exist and must be collected." -Sections @("Architecture","Runbooks","Backups","Monitoring","Patching","Access")

# 02
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\README.md") -Title "02 - Linux Administration" -Purpose "Build a practical Linux operations chapter for daily systems administration." -Sections @(
    "Core Commands",
    "Service Management",
    "Networking",
    "Storage",
    "Logging",
    "Security",
    "Automation"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\core-commands.md") -Title "Core Commands" -Purpose "Collect the Linux commands needed most often." -Sections @("Filesystem","Search","Processes","Packages","Permissions","Examples")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\services.md") -Title "Service Management" -Purpose "Manage and troubleshoot services with systemd." -Sections @("systemctl Basics","Restart Patterns","Failed Services","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\networking.md") -Title "Networking" -Purpose "Troubleshoot Linux networking issues." -Sections @("Interfaces","Routes","Ports","DNS","Firewall","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\storage.md") -Title "Storage" -Purpose "Manage disks, filesystems, and LVM safely." -Sections @("Disk Inventory","Filesystem Usage","Mounts","LVM","Expansion","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\logging.md") -Title "Logging" -Purpose "Use logs for diagnosis and validation." -Sections @("journalctl","System Logs","App Logs","Audit Logs","Log Review Workflow")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\security.md") -Title "Security" -Purpose "Capture Linux security basics relevant to admin work." -Sections @("Users","sudo","Permissions","SSH","SELinux","firewalld")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\02-linux-admin\automation.md") -Title "Automation" -Purpose "Document task automation patterns for Linux admins." -Sections @("Bash Basics","Cron","Health Checks","Update Scripts","Validation")

# 03
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\03-terraform\README.md") -Title "03 - Terraform" -Purpose "Build a practical Terraform learning path for infrastructure administration." -Sections @(
    "Fundamentals",
    "State Management",
    "Modules",
    "Azure Examples",
    "Troubleshooting"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\03-terraform\fundamentals.md") -Title "Terraform Fundamentals" -Purpose "Explain the core building blocks of Terraform." -Sections @("Providers","Resources","Variables","Outputs","Plan and Apply")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\03-terraform\state-management.md") -Title "State Management" -Purpose "Document Terraform state concepts and operational risks." -Sections @("Local State","Remote State","Locking","Drift","Recovery")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\03-terraform\modules.md") -Title "Modules" -Purpose "Describe reusable Terraform design patterns." -Sections @("Why Modules","Inputs","Outputs","Structure","Versioning")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\03-terraform\azure-examples.md") -Title "Azure Examples" -Purpose "Track practical Azure deployment examples with Terraform." -Sections @("Resource Groups","VNets","VMs","NSGs","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\03-terraform\troubleshooting.md") -Title "Terraform Troubleshooting" -Purpose "Capture common Terraform problems and fixes." -Sections @("Init Failures","Plan Errors","State Conflicts","Provider Issues","Drift")

# 04
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\04-azure\README.md") -Title "04 - Azure Infrastructure" -Purpose "Cover the Azure skills most relevant to a systems engineer." -Sections @(
    "VM Deployment",
    "Networking",
    "IAM and RBAC",
    "Monitoring",
    "Security Controls"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\04-azure\vm-deployment.md") -Title "VM Deployment" -Purpose "Document the steps and validation for provisioning Azure VMs." -Sections @("Provisioning","Sizing","Disk Options","Access","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\04-azure\networking.md") -Title "Azure Networking" -Purpose "Track Azure network concepts relevant to admin operations." -Sections @("VNets","Subnets","NSGs","Routing","Connectivity Checks")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\04-azure\iam-rbac.md") -Title "IAM and RBAC" -Purpose "Capture Azure identity and access concepts." -Sections @("RBAC Roles","Scope","Least Privilege","Validation","Common Pitfalls")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\04-azure\monitoring.md") -Title "Monitoring" -Purpose "Track Azure monitoring and alerting practices." -Sections @("Azure Monitor","Log Analytics","Alerts","Health","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\04-azure\security-controls.md") -Title "Security Controls" -Purpose "Document Azure security controls relevant to administrators." -Sections @("NSGs","Defender","Policies","Identity Controls","Auditability")

# 05
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\05-stig-hardening\README.md") -Title "05 - STIG Hardening" -Purpose "Build a practical STIG hardening guide with troubleshooting value." -Sections @(
    "What STIGs Are",
    "Why Systems Break",
    "Common Issues",
    "Troubleshooting",
    "Compliance Workflow"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\05-stig-hardening\what-is-stig.md") -Title "What STIGs Are" -Purpose "Explain STIG baselines and their role in secure environments." -Sections @("Purpose","Scope","Platform Coverage","Operational Impact")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\05-stig-hardening\why-systems-break.md") -Title "Why Systems Break After Hardening" -Purpose "Capture why security changes often create operational failures." -Sections @("Permissions","Services","Authentication","Auditing","Dependencies")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\05-stig-hardening\common-issues.md") -Title "Common STIG Issues" -Purpose "Track the most common breakpoints after applying STIGs." -Sections @("SSH","Service Accounts","File Permissions","Logging","Application Failures")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\05-stig-hardening\troubleshooting.md") -Title "STIG Troubleshooting" -Purpose "Document a repeatable STIG troubleshooting workflow." -Sections @("Change Review","Service Validation","Log Review","Rollback Thinking","Evidence Collection")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\05-stig-hardening\compliance-workflow.md") -Title "Compliance Workflow" -Purpose "Capture the workflow from baseline to validation and evidence." -Sections @("Preparation","Implementation","Validation","Exceptions","Documentation")

# 06
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\06-server-upgrades\README.md") -Title "06 - Server Upgrades" -Purpose "Document safe upgrade planning and execution." -Sections @(
    "Pre-Upgrade Checklist",
    "Snapshot Strategy",
    "Rollback Planning",
    "Testing Strategy",
    "Post-Upgrade Validation"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\06-server-upgrades\pre-upgrade-checklist.md") -Title "Pre-Upgrade Checklist" -Purpose "List what must be checked before touching production systems." -Sections @("Dependencies","Backups","Owners","Maintenance Window","Risk Review")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\06-server-upgrades\rollback-planning.md") -Title "Rollback Planning" -Purpose "Capture rollback planning and recovery expectations." -Sections @("Decision Points","Backup Restore","Snapshot Revert","Communication","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\06-server-upgrades\testing-strategy.md") -Title "Testing Strategy" -Purpose "Document pre-production testing methods." -Sections @("Staging","Test Cases","Compatibility","Functional Validation","Monitoring")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\06-server-upgrades\post-upgrade-validation.md") -Title "Post-Upgrade Validation" -Purpose "Track what must be checked after an upgrade." -Sections @("Service Health","Performance","Logs","Security Controls","User Validation")

# 07
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\07-vulnerability-management\README.md") -Title "07 - Vulnerability Management" -Purpose "Track the vulnerability remediation workflow end to end." -Sections @(
    "Scan Analysis",
    "Prioritization",
    "Patch Workflow",
    "Remediation Validation"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\07-vulnerability-management\scan-analysis.md") -Title "Scan Analysis" -Purpose "Document how scan results should be interpreted." -Sections @("Severity","Asset Context","False Positives","Exposure","Ownership")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\07-vulnerability-management\prioritization.md") -Title "Prioritization" -Purpose "Define how remediation should be prioritized." -Sections @("Criticality","Exploitability","Business Impact","Patch Availability","Sequencing")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\07-vulnerability-management\patch-workflow.md") -Title "Patch Workflow" -Purpose "Capture the patching workflow from review to deployment." -Sections @("Review","Testing","Approval","Deployment","Rollback","Evidence")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\07-vulnerability-management\remediation-validation.md") -Title "Remediation Validation" -Purpose "Document how to prove a vulnerability is truly fixed." -Sections @("Rescans","Manual Checks","Service Validation","Documentation","Closure")

# 08
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\08-12-week-plan\README.md") -Title "08 - 12 Week Plan" -Purpose "Track the weekly growth plan for the first 12 weeks on the job." -Sections @(
    "Weeks 1-4",
    "Weeks 5-8",
    "Weeks 9-12"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\08-12-week-plan\weeks-01-04.md") -Title "Weeks 1-4" -Purpose "Capture survival, discovery, and core stabilization goals." -Sections @("Discovery","Linux","Documentation","Monitoring","Questions")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\08-12-week-plan\weeks-05-08.md") -Title "Weeks 5-8" -Purpose "Capture the build-out of deeper admin and automation skills." -Sections @("Terraform","Azure","STIG","Upgrades","Patch Workflow")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\08-12-week-plan\weeks-09-12.md") -Title "Weeks 9-12" -Purpose "Capture consolidation, documentation, and expert positioning work." -Sections @("Ownership","Documentation","Automation","Remediation","Escalation Readiness")

# 09
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\README.md") -Title "09 - Cyber Range Labs" -Purpose "Design single-VM labs that support practical admin training." -Sections @(
    "Linux Baseline",
    "Service Failure",
    "Disk Pressure",
    "Patching",
    "STIG Hardening",
    "Terraform Workflow"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\lab-01-linux-baseline.md") -Title "Lab 01 - Linux Baseline" -Purpose "Create a clean Linux baseline setup and validation workflow." -Sections @("Objective","Prereqs","Steps","Validation","Common Issues")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\lab-02-service-failure.md") -Title "Lab 02 - Service Failure" -Purpose "Simulate and troubleshoot a failed service." -Sections @("Objective","Failure Injection","Diagnosis","Fix","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\lab-03-disk-pressure.md") -Title "Lab 03 - Disk Pressure" -Purpose "Simulate disk usage problems and recover safely." -Sections @("Objective","Setup","Detection","Cleanup","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\lab-04-patching.md") -Title "Lab 04 - Patching" -Purpose "Practice patching and post-patch verification." -Sections @("Objective","Preparation","Patch","Reboot","Validation")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\lab-05-stig-hardening.md") -Title "Lab 05 - STIG Hardening" -Purpose "Apply secure settings and validate operational impact." -Sections @("Objective","Changes","Breakpoints","Validation","Rollback Thinking")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\09-cyber-range-labs\lab-06-terraform-workflow.md") -Title "Lab 06 - Terraform Workflow" -Purpose "Practice Terraform deployment flow in a controlled lab." -Sections @("Objective","Init","Plan","Apply","Validate","Destroy")

# 10
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\10-scripts\README.md") -Title "10 - Scripts" -Purpose "Track useful admin scripts by technology area." -Sections @(
    "Bash",
    "PowerShell",
    "Terraform",
    "Azure CLI",
    "Troubleshooting"
)
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\10-scripts\bash.md") -Title "Bash Scripts" -Purpose "Collect useful Bash examples." -Sections @("Health Checks","Services","Disk","Logs","Updates")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\10-scripts\terraform.md") -Title "Terraform Scripts" -Purpose "Track reusable Terraform snippets and examples." -Sections @("Providers","Variables","Resources","Outputs","Modules")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\10-scripts\azure-cli.md") -Title "Azure CLI Scripts" -Purpose "Track useful Azure CLI commands and automation patterns." -Sections @("Login","Inventory","VM Actions","Networking","Monitoring")
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\10-scripts\troubleshooting.md") -Title "Troubleshooting Scripts" -Purpose "Collect helpers for diagnosing common issues." -Sections @("Logs","Connectivity","Disk","Performance","Validation")

# 11
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\11-daily-practice\30-minute-routine.md") -Title "30 Minute Practice Routine" -Purpose "Define a daily improvement routine for continuous growth." -Sections @("Linux","Terraform","Azure","Troubleshooting","Reflection")

# 12
New-MarkdownSectionFile -Path (Join-Path $RepoPath "docs\12-six-month-roadmap\team-expert-checklist.md") -Title "Team Expert Checklist" -Purpose "Track the progression from new admin to trusted infrastructure expert." -Sections @("Month 1","Month 2","Month 3","Month 4","Month 5","Month 6")

# ----------------------------
# Labs README
# ----------------------------
$labsReadme = @"
# Labs

This folder contains practical single-VM training exercises organized by topic.

## Folders
- `linux/`
- `azure/`
- `terraform/`
- `stig/`

Each lab should include:
- Objective
- Prerequisites
- Setup
- Steps
- Validation
- Common failure points
"@
New-FileSafe -Path (Join-Path $RepoPath "labs\README.md") -Content $labsReadme

# ----------------------------
# Scripts README
# ----------------------------
$scriptsReadme = @"
# Scripts

This folder contains example automation and troubleshooting helpers.

## Folders
- `bash/`
- `powershell/`
- `terraform/`
- `azure-cli/`

Keep examples small, readable, and operationally useful.
"@
New-FileSafe -Path (Join-Path $RepoPath "scripts\README.md") -Content $scriptsReadme

# ----------------------------
# Diagram placeholders
# ----------------------------
$diagramReadme = @"
# Diagrams

Suggested visuals to add:
- Infrastructure discovery workflow
- Patching workflow
- Vulnerability remediation lifecycle
- STIG break / troubleshoot flow
- Terraform plan â†’ apply â†’ validate flow
- 12-week training roadmap
"@
New-FileSafe -Path (Join-Path $RepoPath "diagrams\README.md") -Content $diagramReadme

# ----------------------------
# Assets placeholder
# ----------------------------
$assetsReadme = @"
# Assets

Use this folder for:
- Repo banner images
- Screenshots
- Overview graphics
- Diagrams exported as PNG or SVG
"@
New-FileSafe -Path (Join-Path $RepoPath "assets\README.md") -Content $assetsReadme

# ----------------------------
# Issue templates
# ----------------------------
$chapterIssue = @"
---
name: Chapter Development
about: Create or expand a chapter in the field guide
title: "docs: add or expand [chapter-name]"
labels: documentation
assignees: ''

---

## Component
Which component is this for?

## Goal
What should this chapter accomplish?

## Required sections
- Purpose
- Scope
- Key concepts
- Commands / workflows
- Troubleshooting
- Validation

## Notes
Add any job-relevant notes here.
"@
New-FileSafe -Path (Join-Path $RepoPath ".github\ISSUE_TEMPLATE\chapter-development.md") -Content $chapterIssue

$labIssue = @"
---
name: Lab Development
about: Add a hands-on lab
title: "labs: add [lab-name]"
labels: labs
assignees: ''

---

## Objective
What skill should this lab teach?

## Prerequisites
What does the lab need?

## Steps
List the core steps.

## Validation
How do we know the lab was completed successfully?

## Failure points
What commonly goes wrong?
"@
New-FileSafe -Path (Join-Path $RepoPath ".github\ISSUE_TEMPLATE\lab-development.md") -Content $labIssue

$scriptIssue = @"
---
name: Script Development
about: Add or improve an automation or troubleshooting script
title: "scripts: add [script-name]"
labels: automation
assignees: ''

---

## Script type
- Bash
- PowerShell
- Terraform
- Azure CLI

## Goal
What should the script do?

## Inputs / outputs
Document expected usage.

## Validation
How will the script be tested?
"@
New-FileSafe -Path (Join-Path $RepoPath ".github\ISSUE_TEMPLATE\script-development.md") -Content $scriptIssue

# ----------------------------
# Starter script examples
# ----------------------------
$bashHealth = @'
#!/usr/bin/env bash
set -euo pipefail

echo "=== Hostname ==="
hostname

echo "=== Uptime ==="
uptime

echo "=== Disk Usage ==="
df -h

echo "=== Memory ==="
free -h || true

echo "=== Failed Services ==="
systemctl --failed || true
'@
New-FileSafe -Path (Join-Path $RepoPath "scripts\bash\health-check.sh") -Content $bashHealth

$psInventory = @'
Write-Host "=== Computer Info ==="
Get-ComputerInfo | Select-Object CsName, WindowsProductName, OsVersion

Write-Host "`n=== Running Services ==="
Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object -First 20

Write-Host "`n=== Disk Usage ==="
Get-PSDrive -PSProvider FileSystem
'@
New-FileSafe -Path (Join-Path $RepoPath "scripts\powershell\windows-inventory.ps1") -Content $psInventory

$tfExample = @'
terraform {
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-sysadmin-field-guide"
  location = "East US"
}
'@
New-FileSafe -Path (Join-Path $RepoPath "scripts\terraform\main.tf") -Content $tfExample

$azCli = @'
az account show
az vm list -o table
az group list -o table
'@
New-FileSafe -Path (Join-Path $RepoPath "scripts\azure-cli\inventory.sh") -Content $azCli

# ----------------------------
# Validation report
# ----------------------------
$expectedFiles = @(
    "README.md",
    "ROADMAP.md",
    "PROJECT_BOARD.md",
    "CONTRIBUTING.md",
    "docs\MASTER_OUTLINE.md",
    "docs\01-first-30-days\README.md",
    "docs\02-linux-admin\README.md",
    "docs\03-terraform\README.md",
    "docs\04-azure\README.md",
    "docs\05-stig-hardening\README.md",
    "docs\06-server-upgrades\README.md",
    "docs\07-vulnerability-management\README.md",
    "docs\08-12-week-plan\README.md",
    "docs\09-cyber-range-labs\README.md",
    "docs\10-scripts\README.md",
    "docs\11-daily-practice\30-minute-routine.md",
    "docs\12-six-month-roadmap\team-expert-checklist.md",
    ".github\ISSUE_TEMPLATE\chapter-development.md",
    ".github\ISSUE_TEMPLATE\lab-development.md",
    ".github\ISSUE_TEMPLATE\script-development.md"
)

$missing = @()
foreach ($relPath in $expectedFiles) {
    $full = Join-Path $RepoPath $relPath
    if (-not (Test-Path $full)) {
        $missing += $relPath
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Validation failed. Missing files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    throw "Repo scaffold validation failed."
}

Write-Host "Validation passed. All expected repo scaffold files were created." -ForegroundColor Green

# ----------------------------
# Optional git init
# ----------------------------
if ($InitializeGit) {
    Push-Location $RepoPath
    try {
        if (-not (Test-Path (Join-Path $RepoPath ".git"))) {
            git init
        }

        git add .
        git commit -m "Initial commit - systems engineer field guide scaffold" 2>$null
        git branch -M main

        Write-Host ""
        Write-Host "Git initialized locally." -ForegroundColor Green
        Write-Host "Next step:" -ForegroundColor Yellow
        Write-Host "git remote add origin https://github.com/$GitHubUser/$RepoName.git"
        Write-Host "git push -u origin main"
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "Repo scaffold build complete." -ForegroundColor Cyan
Write-Host "Location: $RepoPath" -ForegroundColor Cyan

