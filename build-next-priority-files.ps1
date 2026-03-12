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

$azurePath   = Join-Path $RepoPath "docs\04-azure"
$upgradePath = Join-Path $RepoPath "docs\06-server-upgrades"
$vulnPath    = Join-Path $RepoPath "docs\07-vulnerability-management"

Ensure-Directory -Path $azurePath
Ensure-Directory -Path $upgradePath
Ensure-Directory -Path $vulnPath

Write-Section "Building Azure files"

$azureReadme = @'
# 04 - Azure Infrastructure

## Purpose
This section serves as a practical Azure operations guide for systems administrators supporting cloud-hosted infrastructure, access control, monitoring, and security.

## Operational Focus
- VM deployment and administration
- Virtual networking
- IAM and RBAC
- Monitoring and alerting
- Security controls

## Recommended Usage
Use these documents to track Azure concepts, operational workflows, common failure points, validation steps, and lessons learned from lab or production work.

## Files
- `vm-deployment.md`
- `networking.md`
- `iam-rbac.md`
- `monitoring.md`
- `security-controls.md`
'@

$azureVmDeployment = @'
# VM Deployment

## Purpose
Document the process for deploying, validating, and managing Azure virtual machines.

## Core Topics
- Resource group selection
- Region selection
- VM sizing
- OS image choice
- Disk type selection
- Public vs private access
- Admin access method
- Tagging and naming standards

## Portal Workflow
1. Create or select a resource group
2. Choose the VM name and region
3. Select the image and size
4. Configure admin account or SSH key
5. Configure networking
6. Review disks
7. Review management settings
8. Validate before creation
9. Deploy and confirm health

## Azure CLI Examples
```bash
az vm list -o table
az vm show --name MyVm --resource-group MyRg
az vm start --name MyVm --resource-group MyRg
az vm stop --name MyVm --resource-group MyRg
az vm restart --name MyVm --resource-group MyRg
```

## Validation Checklist
- VM exists in correct resource group
- Naming is correct
- Region is correct
- Expected IP and NIC are attached
- Access works
- Boot diagnostics or health indicators are clean

## Common Problems
- Wrong subnet or NSG attached
- Incorrect VM size
- Login method misconfigured
- Public IP assigned when it should not be
- Missing tags or naming standard
'@

$azureNetworking = @'
# Azure Networking

## Purpose
Provide a practical guide for understanding and validating Azure network configuration.

## Core Concepts
- Virtual Networks (VNets)
- Subnets
- Network Security Groups (NSGs)
- Route tables
- Public IP addresses
- Private IP addressing
- NIC associations

## What to Check First
- What VNet is the VM in?
- What subnet is it attached to?
- Is there an NSG on the NIC, subnet, or both?
- Does it need public access?
- Are routing rules affecting reachability?

## Azure CLI Examples
```bash
az network vnet list -o table
az network vnet subnet list --resource-group MyRg --vnet-name MyVnet -o table
az network nsg list -o table
az network nic list -o table
```

## Troubleshooting Workflow
1. Confirm the VM is running
2. Confirm the NIC is attached correctly
3. Confirm IP addressing
4. Review NSG rules
5. Review subnet and route configuration
6. Test expected connectivity
7. Confirm service is listening on the VM

## Validation Checklist
- VM is attached to intended VNet/subnet
- NSG rules permit expected traffic only
- Routing is understood
- Required ports are reachable
- Unnecessary exposure is avoided

## Common Problems
- NSG blocks required traffic
- Wrong subnet assignment
- Misunderstood public/private access
- Route table causes path issue
- App is down even though network path is open
'@

$azureIamRbac = @'
# IAM and RBAC

## Purpose
Track how Azure identity and access should be understood and validated by a systems administrator.

## Core Concepts
- Azure AD / Entra identity context
- Role-Based Access Control (RBAC)
- Scope: management group, subscription, resource group, resource
- Least privilege
- Role assignment review

## Common Roles to Understand
- Reader
- Virtual Machine Contributor
- Network Contributor
- Contributor
- Owner

## Key Questions
- Who has access?
- At what scope is access assigned?
- Is the access broader than necessary?
- Are service principals or automation identities in use?
- Are there stale or inherited permissions?

## Azure CLI Examples
```bash
az role assignment list --all -o table
az role assignment list --assignee user@domain.com -o table
az role definition list --name Contributor -o json
```

## Validation Checklist
- Access is scoped appropriately
- Elevated roles are justified
- Automation identities are documented
- Unexpected assignments are investigated
- Least privilege is being followed

## Common Problems
- Overly broad Contributor or Owner access
- Unknown inherited permissions
- Untracked service principals
- Access granted at subscription scope when resource group scope was enough
'@

$azureMonitoring = @'
# Monitoring

## Purpose
Document the Azure monitoring tools and workflows most relevant to infrastructure administration.

## Core Components
- Azure Monitor
- Activity Log
- Metrics
- Alerts
- Log Analytics
- Diagnostic settings

## What to Monitor
- VM health
- CPU and memory trends
- Disk performance
- Network metrics
- Restart events
- Administrative changes
- Failed login or access anomalies where applicable

## Azure CLI Examples
```bash
az monitor metrics list --resource <resource-id> --metric "Percentage CPU"
az monitor activity-log list --max-events 20
az monitor log-analytics workspace list -o table
```

## Operational Workflow
1. Confirm what telemetry is enabled
2. Review recent alerts
3. Review activity logs for admin changes
4. Review performance data
5. Correlate system symptoms with Azure events
6. Capture findings and next actions

## Validation Checklist
- Monitoring is enabled where needed
- Alerts are actionable
- Noise is reduced
- Logs are retained appropriately
- Ops team knows where to look first

## Common Problems
- Monitoring not enabled
- Too many noisy alerts
- Metrics available but unused
- No retention or unclear ownership
'@

$azureSecurityControls = @'
# Security Controls

## Purpose
Capture the Azure security controls most important for secure systems administration.

## Core Areas
- Network Security Groups
- Azure Policy
- Defender for Cloud
- Identity controls
- Resource exposure review
- Baseline configuration standards

## Questions to Ask
- What resources are internet-exposed?
- Are policies enforcing standards?
- Is Defender enabled?
- Are NSGs restrictive enough?
- Are admin accounts protected?
- Are there configuration drifts from standard?

## Azure CLI Examples
```bash
az policy assignment list -o table
az security pricing list -o table
az resource list --query "[].{Name:name,Type:type,Group:resourceGroup}" -o table
```

## Validation Checklist
- Security controls are enabled and understood
- Internet exposure is intentional
- Policies align with standards
- High-risk findings are tracked
- Admin access is controlled

## Common Problems
- Unrestricted NSG rules
- Resources deployed outside standard policy
- Defender recommendations ignored
- Public exposure not documented
'@

Write-Utf8File -Path (Join-Path $azurePath "README.md") -Content $azureReadme
Write-Utf8File -Path (Join-Path $azurePath "vm-deployment.md") -Content $azureVmDeployment
Write-Utf8File -Path (Join-Path $azurePath "networking.md") -Content $azureNetworking
Write-Utf8File -Path (Join-Path $azurePath "iam-rbac.md") -Content $azureIamRbac
Write-Utf8File -Path (Join-Path $azurePath "monitoring.md") -Content $azureMonitoring
Write-Utf8File -Path (Join-Path $azurePath "security-controls.md") -Content $azureSecurityControls

Write-Section "Building Server Upgrade files"

$upgradeReadme = @'
# 06 - Server Upgrades

## Purpose
This section provides a structured upgrade and patching reference for systems administrators managing planned change in enterprise environments.

## Operational Focus
- Pre-upgrade preparation
- Snapshot and backup strategy
- Rollback planning
- Testing approach
- Post-upgrade validation

## Recommended Usage
Use these documents to plan safer upgrades, reduce unplanned downtime, and capture evidence of successful change execution.

## Files
- `pre-upgrade-checklist.md`
- `rollback-planning.md`
- `testing-strategy.md`
- `post-upgrade-validation.md`
'@

$upgradePre = @'
# Pre-Upgrade Checklist

## Purpose
Document the checks that should be completed before any server upgrade or major patch activity.

## Core Checklist
- Confirm maintenance window
- Identify system owner
- Confirm business impact
- Review dependencies
- Confirm backup or snapshot status
- Review current version and target version
- Review vendor or platform release notes
- Review known compatibility concerns
- Confirm validation plan exists
- Confirm rollback plan exists

## Questions to Answer
- What depends on this system?
- What will be unavailable during the change?
- Is a reboot expected?
- Is the application owner aware?
- What is the recovery point if this fails?

## Evidence to Capture
- Current version
- Current service state
- Backup confirmation
- Screenshot or command outputs showing baseline condition
- Ticket / change reference

## Validation Checklist
- All dependencies identified
- Owners notified
- Backup confirmed
- Test and rollback plans written down
- Change can be executed in a controlled way
'@

$upgradeRollback = @'
# Rollback Planning

## Purpose
Document how to recover if an upgrade causes service failure, instability, or unexpected behavior.

## Core Rollback Questions
- What is the trigger to rollback?
- Who makes the rollback decision?
- What backup or snapshot is available?
- How long will rollback take?
- What service validation proves recovery?

## Rollback Options
- Restore snapshot
- Restore VM backup
- Reinstall prior package version if supported
- Revert application configuration
- Fail over to alternate node if available

## Decision Triggers
- Service will not start
- Application health check fails
- Network functionality is broken
- Security control or required logging is lost
- Performance degradation is unacceptable

## Validation Checklist
- Recovery path is known before change starts
- Team knows where the restore point is
- Decision thresholds are defined
- Post-rollback validation steps are documented
'@

$upgradeTesting = @'
# Testing Strategy

## Purpose
Provide a structured way to test upgrades before and after implementation.

## Pre-Change Testing
- Test in lab or staging if possible
- Review compatibility with application stack
- Confirm startup behavior after reboot
- Confirm required services remain enabled
- Confirm logging and monitoring still work

## Functional Test Categories
- Service starts
- Port is listening
- App responds correctly
- Authentication works
- Scheduled tasks work
- Logging works
- Monitoring still receives data

## Suggested Validation Commands
```bash
systemctl --failed
systemctl status <service>
journalctl -xe
ss -tulpn
df -h
```

## Post-Upgrade Test Pattern
1. Confirm system boots correctly
2. Confirm required services are active
3. Confirm application functionality
4. Confirm network connectivity
5. Confirm logs are healthy
6. Confirm monitoring is normal

## Validation Checklist
- Test plan exists before change
- Same checks are used consistently
- Results are documented
- Failures are captured with evidence
'@

$upgradePost = @'
# Post-Upgrade Validation

## Purpose
Capture what must be checked immediately after an upgrade or major patch event.

## Immediate Checks
- System is online
- Expected services are active
- Expected ports are listening
- Application responds correctly
- No obvious new log errors
- Monitoring sees the system
- Security controls still hold

## Linux Validation Examples
```bash
hostnamectl
uptime
systemctl --failed
journalctl -p err -b
ss -tulpn
df -h
```

## Questions to Confirm
- Did all services come back?
- Did any new errors appear?
- Did firewall or SELinux behavior change?
- Did a reboot change network behavior?
- Did application owners validate functionality?

## Evidence to Capture
- Service status output
- Log excerpts
- App health result
- Monitoring screenshot or check result
- Completion note in change ticket

## Validation Checklist
- Technical checks passed
- Functional checks passed
- Security checks passed
- Evidence recorded
- Stakeholders notified
'@

Write-Utf8File -Path (Join-Path $upgradePath "README.md") -Content $upgradeReadme
Write-Utf8File -Path (Join-Path $upgradePath "pre-upgrade-checklist.md") -Content $upgradePre
Write-Utf8File -Path (Join-Path $upgradePath "rollback-planning.md") -Content $upgradeRollback
Write-Utf8File -Path (Join-Path $upgradePath "testing-strategy.md") -Content $upgradeTesting
Write-Utf8File -Path (Join-Path $upgradePath "post-upgrade-validation.md") -Content $upgradePost

Write-Section "Building Vulnerability Management files"

$vulnReadme = @'
# 07 - Vulnerability Management

## Purpose
This section provides a practical vulnerability remediation workflow for administrators responsible for scan analysis, prioritization, patch planning, and validation.

## Operational Focus
- Scan analysis
- Prioritization
- Patch workflow
- Remediation validation

## Recommended Usage
Use these documents to track how findings are reviewed, prioritized, fixed, re-tested, and documented in secure environments.

## Files
- `scan-analysis.md`
- `prioritization.md`
- `patch-workflow.md`
- `remediation-validation.md`
'@

$vulnScan = @'
# Scan Analysis

## Purpose
Document how vulnerability scan results should be interpreted before action is taken.

## Core Review Areas
- Severity
- CVE details
- Affected package or software
- Asset criticality
- Exposure level
- Patch availability
- Potential false positive conditions

## Questions to Ask
- Is the finding on a critical system?
- Is there known exploit activity?
- Is the package actually installed and active?
- Is the reported version accurate?
- Is compensating control already in place?

## Workflow
1. Review the finding details
2. Confirm affected host and asset role
3. Confirm the vulnerable component exists
4. Check for patch or remediation guidance
5. Identify urgency based on risk
6. Track needed action

## Validation Checklist
- Finding reviewed, not blindly accepted
- Asset context understood
- Patch path identified
- False positives considered
- Owner assigned
'@

$vulnPrioritization = @'
# Prioritization

## Purpose
Define how vulnerability findings should be ranked so the most important risks are handled first.

## Common Priority Factors
- CVSS severity
- Known exploit availability
- Internet exposure
- Business criticality
- Presence of sensitive data
- Ease of remediation
- Patch availability

## Example Priority Logic
### Highest Priority
- Critical finding
- Publicly exposed system
- Known exploit exists
- High-value or mission-critical asset

### Medium Priority
- Important but not internet-facing
- Exploit less likely
- Moderate business impact

### Lower Priority
- Limited exposure
- Compensating controls exist
- Patch can be scheduled safely

## Questions to Ask
- What is the blast radius if exploited?
- Is the system externally reachable?
- Is a compensating control already reducing the risk?
- Will patching break production?

## Validation Checklist
- Priorities are based on risk, not just scanner score
- Critical assets are escalated appropriately
- Patch windows align with urgency
- Exception paths are documented if needed
'@

$vulnPatch = @'
# Patch Workflow

## Purpose
Document the operational workflow for moving from vulnerability finding to deployed fix.

## Workflow
1. Review finding
2. Confirm affected asset
3. Confirm patch or mitigation path
4. Test when possible
5. Schedule deployment
6. Apply patch or remediation
7. Validate service health
8. Re-scan or verify
9. Record evidence and close

## Operational Checks
- Is a reboot required?
- Is downtime needed?
- Is rollback available?
- Are app owners informed?
- Is validation documented?

## Linux Patch Examples
```bash
dnf check-update
dnf update -y
rpm -qa | sort
journalctl -p err -b
systemctl --failed
```

## Validation Checklist
- Patch or mitigation was actually applied
- Services remain healthy
- Logs are reviewed after change
- Reboot impact is understood
- Evidence captured in ticket or tracker
'@

$vulnValidation = @'
# Remediation Validation

## Purpose
Document how to prove that a vulnerability was actually remediated and did not create new operational problems.

## Validation Methods
- Re-scan the asset
- Confirm package version changed
- Confirm vulnerable service no longer exposed
- Confirm mitigation was applied correctly
- Confirm system functionality remains healthy

## Example Linux Validation
```bash
rpm -qa | sort
dnf history
systemctl --failed
journalctl -p err -b
ss -tulpn
```

## Questions to Answer
- Did the finding disappear on re-scan?
- Did the package version update?
- Did the service stay healthy?
- Was a temporary mitigation removed after permanent fix?
- Was the evidence recorded?

## Evidence to Capture
- Scan result before and after
- Package/version evidence
- Service status
- Log review output
- Ticket or change reference

## Validation Checklist
- Fix verified technically
- Service verified functionally
- Evidence recorded
- Closure justified
'@

Write-Utf8File -Path (Join-Path $vulnPath "README.md") -Content $vulnReadme
Write-Utf8File -Path (Join-Path $vulnPath "scan-analysis.md") -Content $vulnScan
Write-Utf8File -Path (Join-Path $vulnPath "prioritization.md") -Content $vulnPrioritization
Write-Utf8File -Path (Join-Path $vulnPath "patch-workflow.md") -Content $vulnPatch
Write-Utf8File -Path (Join-Path $vulnPath "remediation-validation.md") -Content $vulnValidation

Write-Section "Running validation" "Green"

$expectedFiles = @(
    "docs\04-azure\README.md",
    "docs\04-azure\vm-deployment.md",
    "docs\04-azure\networking.md",
    "docs\04-azure\iam-rbac.md",
    "docs\04-azure\monitoring.md",
    "docs\04-azure\security-controls.md",
    "docs\06-server-upgrades\README.md",
    "docs\06-server-upgrades\pre-upgrade-checklist.md",
    "docs\06-server-upgrades\rollback-planning.md",
    "docs\06-server-upgrades\testing-strategy.md",
    "docs\06-server-upgrades\post-upgrade-validation.md",
    "docs\07-vulnerability-management\README.md",
    "docs\07-vulnerability-management\scan-analysis.md",
    "docs\07-vulnerability-management\prioritization.md",
    "docs\07-vulnerability-management\patch-workflow.md",
    "docs\07-vulnerability-management\remediation-validation.md"
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
Write-Host "Validation passed. All next-priority files were created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "cd `"$RepoPath`""
Write-Host "git add ."
Write-Host 'git commit -m "docs: build azure upgrade and vulnerability files"'
Write-Host "git push"
