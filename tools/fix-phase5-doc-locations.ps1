[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

function Ensure-Dir {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
}

function Move-IfExists {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Source) {
        $parent = Split-Path -Parent $Destination
        Ensure-Dir -Path $parent
        Move-Item -LiteralPath $Source -Destination $Destination -Force
        Write-Host "Moved: $Source -> $Destination" -ForegroundColor Green
    }
    else {
        Write-Host "Missing source, skipped: $Source" -ForegroundColor DarkGray
    }
}

Write-Step "Validating repo"

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "Repo root not found: $RepoRoot"
}

Set-Location $RepoRoot

Write-Step "Ensuring destination folders"

$destDirs = @(
    "docs\case-studies",
    "docs\labs",
    "docs\scripts"
)

foreach ($dir in $destDirs) {
    Ensure-Dir -Path (Join-Path $RepoRoot $dir)
}

Write-Step "Moving case studies"

Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\case-studies\server-upgrade-lifecycle.md") -Destination (Join-Path $RepoRoot "docs\case-studies\server-upgrade-lifecycle.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\case-studies\stig-remediation-project.md") -Destination (Join-Path $RepoRoot "docs\case-studies\stig-remediation-project.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\case-studies\terraform-deployment-standardization.md") -Destination (Join-Path $RepoRoot "docs\case-studies\terraform-deployment-standardization.md")

Write-Step "Moving labs"

Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\labs\README.md") -Destination (Join-Path $RepoRoot "docs\labs\README.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\labs\linux-monitoring-and-log-validation.md") -Destination (Join-Path $RepoRoot "docs\labs\linux-monitoring-and-log-validation.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\labs\stig-hardening-validation.md") -Destination (Join-Path $RepoRoot "docs\labs\stig-hardening-validation.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\labs\terraform-azure-deployment-validation.md") -Destination (Join-Path $RepoRoot "docs\labs\terraform-azure-deployment-validation.md")

Write-Step "Moving script docs"

Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\scripts\add-scenarios-playbooks-and-reference.md") -Destination (Join-Path $RepoRoot "docs\scripts\add-scenarios-playbooks-and-reference.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\scripts\add-security-metrics-and-architecture.md") -Destination (Join-Path $RepoRoot "docs\scripts\add-security-metrics-and-architecture.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\scripts\script-documentation-template.md") -Destination (Join-Path $RepoRoot "docs\scripts\script-documentation-template.md")
Move-IfExists -Source (Join-Path $RepoRoot "tools\docs\scripts\upgrade-readme-systems-engineer-priority-1.md") -Destination (Join-Path $RepoRoot "docs\scripts\upgrade-readme-systems-engineer-priority-1.md")

Write-Step "Removing leftover tools/docs tree if empty"

$pathsToTry = @(
    (Join-Path $RepoRoot "tools\docs\case-studies"),
    (Join-Path $RepoRoot "tools\docs\labs"),
    (Join-Path $RepoRoot "tools\docs\scripts"),
    (Join-Path $RepoRoot "tools\docs")
)

foreach ($path in $pathsToTry) {
    if (Test-Path -LiteralPath $path) {
        $items = Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue
        if (-not $items) {
            Remove-Item -LiteralPath $path -Force
            Write-Host "Removed empty folder: $path" -ForegroundColor Yellow
        }
        else {
            Write-Host "Folder not empty, left in place: $path" -ForegroundColor DarkGray
        }
    }
}

Write-Step "Complete"

Write-Host "Phase 5 files moved to correct docs locations." -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Yellow
Write-Host "git status"
Write-Host "git add docs tools"
Write-Host "git commit -m `"docs: fix phase 5 file locations`""
Write-Host "git push"