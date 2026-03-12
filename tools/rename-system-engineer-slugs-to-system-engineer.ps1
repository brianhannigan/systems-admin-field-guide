<#
.SYNOPSIS
Second-pass recursive rename for slug, plural, and hyphenated variants:
- systems-engineer -> systems-engineer
- system-engineer  -> system-engineer
- systems engineer(s) -> systems engineer(s)
- systems engineer(s) -> systems engineer(s)
- system engineer(s) -> system engineer(s)
- system engineer(s) -> system engineer(s)

.DESCRIPTION
Processes file contents, file names, and directory names under the specified root.
Supports -DryRun and PowerShell ShouldProcess (-WhatIf / -Confirm).
Skips common generated/binary directories by default.

.EXAMPLE
cd "C:\Users\BrianH\Documents\0000 - Portfolio\systems-engineer-field-guide"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\rename-system-engineer-slugs-to-system-engineer.ps1 -DryRun

.EXAMPLE
.\tools\rename-system-engineer-slugs-to-system-engineer.ps1

.EXAMPLE
.\tools\rename-system-engineer-slugs-to-system-engineer.ps1 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter()]
    [string]$RootPath = (Get-Location).Path,

    [Parameter()]
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

function Assert-RootPath {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Root path does not exist: $Path"
    }

    $item = Get-Item -LiteralPath $Path
    if (-not $item.PSIsContainer) {
        throw "Root path is not a directory: $Path"
    }
}

function Add-LogLine {
    param(
        [string]$LogFile,
        [string]$Message
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $LogFile -Value "[$timestamp] $Message"
}

function Test-IsExcludedPath {
    param([string]$Path)

    $excludedNames = @(
        '.git',
        '.vs',
        'bin',
        'obj',
        'node_modules',
        'packages',
        'dist',
        'build',
        'coverage'
    )

    $normalized = $Path.Replace('/', '\')

    foreach ($name in $excludedNames) {
        if ($normalized -match "(^|\\)$([regex]::Escape($name))(\\|$)") {
            return $true
        }
    }

    return $false
}

function Get-SafeTextExtensions {
    @(
        '.txt', '.md', '.markdown', '.ps1', '.psm1', '.psd1', '.sh', '.bash',
        '.zsh', '.cmd', '.bat', '.py', '.rb', '.php', '.pl', '.json', '.yaml',
        '.yml', '.xml', '.config', '.ini', '.csv', '.tsv', '.sql', '.tf',
        '.tfvars', '.hcl', '.cs', '.csproj', '.sln', '.vb', '.js', '.ts', '.tsx',
        '.jsx', '.html', '.htm', '.css', '.scss', '.less', '.java', '.go', '.rs',
        '.c', '.cpp', '.h', '.hpp', '.swift', '.kt', '.kts', '.r', '.m', '.tex',
        '.adoc', '.rst', '.gitignore', '.gitattributes', '.editorconfig',
        '.env', '.sample', '.example'
    )
}

function Test-IsLikelyTextFile {
    param([System.IO.FileInfo]$File)

    $safeExtensions = Get-SafeTextExtensions
    $ext = $File.Extension.ToLowerInvariant()

    if ($safeExtensions -contains $ext) {
        return $true
    }

    if ([string]::IsNullOrWhiteSpace($ext)) {
        return $true
    }

    return $false
}

function Replace-SlugAndPluralPhrases {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $updated = $Text

    # Uppercase variants
    $updated = [regex]::Replace($updated, '\bSYSTEMS-ADMIN\b', 'SYSTEMS-ENGINEER')
    $updated = [regex]::Replace($updated, '\bSYSTEM-ADMIN\b', 'SYSTEM-ENGINEER')
    $updated = [regex]::Replace($updated, '\bSYSTEMS ADMINISTRATORS\b', 'SYSTEMS ENGINEERS')
    $updated = [regex]::Replace($updated, '\bSYSTEMS ADMINISTRATOR\b', 'SYSTEMS ENGINEER')
    $updated = [regex]::Replace($updated, '\bSYSTEMS ADMINS\b', 'SYSTEMS ENGINEERS')
    $updated = [regex]::Replace($updated, '\bSYSTEMS ADMIN\b', 'SYSTEMS ENGINEER')
    $updated = [regex]::Replace($updated, '\bSYSTEM ADMINISTRATORS\b', 'SYSTEM ENGINEERS')
    $updated = [regex]::Replace($updated, '\bSYSTEM ADMINISTRATOR\b', 'SYSTEM ENGINEER')
    $updated = [regex]::Replace($updated, '\bSYSTEM ADMINS\b', 'SYSTEM ENGINEERS')
    $updated = [regex]::Replace($updated, '\bSYSTEM ADMIN\b', 'SYSTEM ENGINEER')

    # Title case variants
    $updated = [regex]::Replace($updated, '\bSystems-Admin\b', 'Systems-Engineer')
    $updated = [regex]::Replace($updated, '\bSystem-Admin\b', 'System-Engineer')
    $updated = [regex]::Replace($updated, '\bSystems Administrators\b', 'Systems Engineers')
    $updated = [regex]::Replace($updated, '\bSystems Administrator\b', 'Systems Engineer')
    $updated = [regex]::Replace($updated, '\bSystems Admins\b', 'Systems Engineers')
    $updated = [regex]::Replace($updated, '\bSystems Admin\b', 'Systems Engineer')
    $updated = [regex]::Replace($updated, '\bSystem Administrators\b', 'System Engineers')
    $updated = [regex]::Replace($updated, '\bSystem Administrator\b', 'System Engineer')
    $updated = [regex]::Replace($updated, '\bSystem Admins\b', 'System Engineers')
    $updated = [regex]::Replace($updated, '\bSystem Admin\b', 'System Engineer')

    # Lowercase variants
    $updated = [regex]::Replace($updated, '\bsystems-admin\b', 'systems-engineer')
    $updated = [regex]::Replace($updated, '\bsystem-admin\b', 'system-engineer')
    $updated = [regex]::Replace($updated, '\bsystems administrators\b', 'systems engineers')
    $updated = [regex]::Replace($updated, '\bsystems administrator\b', 'systems engineer')
    $updated = [regex]::Replace($updated, '\bsystems admins\b', 'systems engineers')
    $updated = [regex]::Replace($updated, '\bsystems admin\b', 'systems engineer')
    $updated = [regex]::Replace($updated, '\bsystem administrators\b', 'system engineers')
    $updated = [regex]::Replace($updated, '\bsystem administrator\b', 'system engineer')
    $updated = [regex]::Replace($updated, '\bsystem admins\b', 'system engineers')
    $updated = [regex]::Replace($updated, '\bsystem admin\b', 'system engineer')

    return $updated
}

function Get-RenamedLeaf {
    param([string]$LeafName)

    if ([string]::IsNullOrEmpty($LeafName)) {
        return $LeafName
    }

    return (Replace-SlugAndPluralPhrases -Text $LeafName)
}

Write-Step "Validation"

Assert-RootPath -Path $RootPath
$resolvedRoot = (Resolve-Path -LiteralPath $RootPath).Path

$logDir = Join-Path $resolvedRoot 'tools'
if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$logFile = Join-Path $logDir ("rename-system-engineer-slugs-to-system-engineer_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

Add-LogLine -LogFile $logFile -Message "Starting slug/plural rename operation at root: $resolvedRoot"
Add-LogLine -LogFile $logFile -Message "DryRun: $DryRun"

Write-Host "Root Path : $resolvedRoot" -ForegroundColor Green
Write-Host "Log File  : $logFile" -ForegroundColor Green
Write-Host "Dry Run   : $DryRun" -ForegroundColor Yellow

Write-Step "Inventory"

$allFiles = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force | Where-Object {
    -not (Test-IsExcludedPath -Path $_.FullName)
}

$allDirectories = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Directory -Force | Where-Object {
    -not (Test-IsExcludedPath -Path $_.FullName)
} | Sort-Object FullName -Descending

$fileContentCandidates = @()
$fileRenameCandidates = @()
$directoryRenameCandidates = @()

foreach ($file in $allFiles) {
    if (Test-IsLikelyTextFile -File $file) {
        $fileContentCandidates += $file
    }

    $newLeaf = Get-RenamedLeaf -LeafName $file.Name
    if ($newLeaf -ne $file.Name) {
        $fileRenameCandidates += [PSCustomObject]@{
            Type    = 'FileName'
            OldPath = $file.FullName
            NewPath = Join-Path $file.DirectoryName $newLeaf
        }
    }
}

foreach ($dir in $allDirectories) {
    $newLeaf = Get-RenamedLeaf -LeafName $dir.Name
    if ($newLeaf -ne $dir.Name) {
        $directoryRenameCandidates += [PSCustomObject]@{
            Type    = 'DirectoryName'
            OldPath = $dir.FullName
            NewPath = Join-Path $dir.Parent.FullName $newLeaf
        }
    }
}

Write-Host ("Text content candidates : {0}" -f $fileContentCandidates.Count) -ForegroundColor Gray
Write-Host ("File rename candidates  : {0}" -f $fileRenameCandidates.Count) -ForegroundColor Gray
Write-Host ("Dir rename candidates   : {0}" -f $directoryRenameCandidates.Count) -ForegroundColor Gray

Add-LogLine -LogFile $logFile -Message "Text content candidates: $($fileContentCandidates.Count)"
Add-LogLine -LogFile $logFile -Message "File rename candidates: $($fileRenameCandidates.Count)"
Add-LogLine -LogFile $logFile -Message "Directory rename candidates: $($directoryRenameCandidates.Count)"

Write-Step "Updating file contents"

$contentUpdatedCount = 0
$contentSkippedCount = 0
$contentErrorCount = 0

foreach ($file in $fileContentCandidates) {
    try {
        $original = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
        $updated = Replace-SlugAndPluralPhrases -Text $original

        if ($updated -ne $original) {
            if ($DryRun) {
                Write-Host "[DRYRUN] Content update: $($file.FullName)" -ForegroundColor Yellow
                Add-LogLine -LogFile $logFile -Message "[DRYRUN] Content update: $($file.FullName)"
                $contentUpdatedCount++
            }
            else {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Update slug/plural references to system engineer")) {
                    Set-Content -LiteralPath $file.FullName -Value $updated -Encoding UTF8
                    Write-Host "Updated content: $($file.FullName)" -ForegroundColor Green
                    Add-LogLine -LogFile $logFile -Message "Updated content: $($file.FullName)"
                    $contentUpdatedCount++
                }
            }
        }
        else {
            $contentSkippedCount++
        }
    }
    catch {
        $contentErrorCount++
        Write-Warning "Failed content update: $($file.FullName) :: $($_.Exception.Message)"
        Add-LogLine -LogFile $logFile -Message "ERROR content update: $($file.FullName) :: $($_.Exception.Message)"
    }
}

Write-Step "Renaming files"

$fileRenamedCount = 0
$fileRenameErrorCount = 0

foreach ($candidate in $fileRenameCandidates) {
    try {
        if (Test-Path -LiteralPath $candidate.NewPath) {
            throw "Target already exists: $($candidate.NewPath)"
        }

        if ($DryRun) {
            Write-Host "[DRYRUN] File rename: $($candidate.OldPath) -> $($candidate.NewPath)" -ForegroundColor Yellow
            Add-LogLine -LogFile $logFile -Message "[DRYRUN] File rename: $($candidate.OldPath) -> $($candidate.NewPath)"
            $fileRenamedCount++
        }
        else {
            if ($PSCmdlet.ShouldProcess($candidate.OldPath, "Rename file to '$($candidate.NewPath)'")) {
                Rename-Item -LiteralPath $candidate.OldPath -NewName (Split-Path $candidate.NewPath -Leaf)
                Write-Host "Renamed file: $($candidate.OldPath) -> $($candidate.NewPath)" -ForegroundColor Green
                Add-LogLine -LogFile $logFile -Message "Renamed file: $($candidate.OldPath) -> $($candidate.NewPath)"
                $fileRenamedCount++
            }
        }
    }
    catch {
        $fileRenameErrorCount++
        Write-Warning "Failed file rename: $($candidate.OldPath) :: $($_.Exception.Message)"
        Add-LogLine -LogFile $logFile -Message "ERROR file rename: $($candidate.OldPath) :: $($_.Exception.Message)"
    }
}

Write-Step "Renaming directories"

$directoryRenamedCount = 0
$directoryRenameErrorCount = 0

foreach ($candidate in $directoryRenameCandidates) {
    try {
        if (Test-Path -LiteralPath $candidate.NewPath) {
            throw "Target already exists: $($candidate.NewPath)"
        }

        if ($DryRun) {
            Write-Host "[DRYRUN] Directory rename: $($candidate.OldPath) -> $($candidate.NewPath)" -ForegroundColor Yellow
            Add-LogLine -LogFile $logFile -Message "[DRYRUN] Directory rename: $($candidate.OldPath) -> $($candidate.NewPath)"
            $directoryRenamedCount++
        }
        else {
            if ($PSCmdlet.ShouldProcess($candidate.OldPath, "Rename directory to '$($candidate.NewPath)'")) {
                Rename-Item -LiteralPath $candidate.OldPath -NewName (Split-Path $candidate.NewPath -Leaf)
                Write-Host "Renamed directory: $($candidate.OldPath) -> $($candidate.NewPath)" -ForegroundColor Green
                Add-LogLine -LogFile $logFile -Message "Renamed directory: $($candidate.OldPath) -> $($candidate.NewPath)"
                $directoryRenamedCount++
            }
        }
    }
    catch {
        $directoryRenameErrorCount++
        Write-Warning "Failed directory rename: $($candidate.OldPath) :: $($_.Exception.Message)"
        Add-LogLine -LogFile $logFile -Message "ERROR directory rename: $($candidate.OldPath) :: $($_.Exception.Message)"
    }
}

Write-Step "Final validation scan"

$remainingMatches = @()
$textFilesForRescan = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force | Where-Object {
    -not (Test-IsExcludedPath -Path $_.FullName) -and (Test-IsLikelyTextFile -File $_)
}

foreach ($file in $textFilesForRescan) {
    try {
        $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
        if (
            $text -match '(?i)\bsystems-admin\b' -or
            $text -match '(?i)\bsystem-admin\b' -or
            $text -match '(?i)\bsystems administrators?\b' -or
            $text -match '(?i)\bsystems admins?\b' -or
            $text -match '(?i)\bsystem administrators?\b' -or
            $text -match '(?i)\bsystem admins?\b'
        ) {
            $remainingMatches += $file.FullName
        }
    }
    catch {
        Add-LogLine -LogFile $logFile -Message "WARN rescan failed: $($file.FullName) :: $($_.Exception.Message)"
    }
}

$remainingNameMatches = @()
$allItemsForRescan = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Force | Where-Object {
    -not (Test-IsExcludedPath -Path $_.FullName)
}

foreach ($item in $allItemsForRescan) {
    if (
        $item.Name -match '(?i)systems-engineer' -or
        $item.Name -match '(?i)system-engineer' -or
        $item.Name -match '(?i)systems engineers?' -or
        $item.Name -match '(?i)systems engineers?' -or
        $item.Name -match '(?i)system engineers?' -or
        $item.Name -match '(?i)system engineers?'
    ) {
        $remainingNameMatches += $item.FullName
    }
}

Write-Step "Summary"

Write-Host ("Content updates attempted : {0}" -f $contentUpdatedCount) -ForegroundColor Green
Write-Host ("Content skipped          : {0}" -f $contentSkippedCount) -ForegroundColor Gray
Write-Host ("Content errors           : {0}" -f $contentErrorCount) -ForegroundColor Red
Write-Host ("File renames attempted   : {0}" -f $fileRenamedCount) -ForegroundColor Green
Write-Host ("File rename errors       : {0}" -f $fileRenameErrorCount) -ForegroundColor Red
Write-Host ("Dir renames attempted    : {0}" -f $directoryRenamedCount) -ForegroundColor Green
Write-Host ("Dir rename errors        : {0}" -f $directoryRenameErrorCount) -ForegroundColor Red
Write-Host ("Remaining text matches   : {0}" -f $remainingMatches.Count) -ForegroundColor Yellow
Write-Host ("Remaining name matches   : {0}" -f $remainingNameMatches.Count) -ForegroundColor Yellow
Write-Host ("Log file                 : {0}" -f $logFile) -ForegroundColor Cyan

Add-LogLine -LogFile $logFile -Message "Summary: contentUpdated=$contentUpdatedCount, contentSkipped=$contentSkippedCount, contentErrors=$contentErrorCount, fileRenamed=$fileRenamedCount, fileRenameErrors=$fileRenameErrorCount, directoryRenamed=$directoryRenamedCount, directoryRenameErrors=$directoryRenameErrorCount, remainingTextMatches=$($remainingMatches.Count), remainingNameMatches=$($remainingNameMatches.Count)"

if ($remainingMatches.Count -gt 0) {
    Write-Host ""
    Write-Host "Remaining text matches:" -ForegroundColor Yellow
    $remainingMatches | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
}

if ($remainingNameMatches.Count -gt 0) {
    Write-Host ""
    Write-Host "Remaining file/folder name matches:" -ForegroundColor Yellow
    $remainingNameMatches | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "Recommended commands:" -ForegroundColor Cyan
Write-Host ".\tools\rename-system-engineer-slugs-to-system-engineer.ps1 -DryRun"
Write-Host ".\tools\rename-system-engineer-slugs-to-system-engineer.ps1"
Write-Host "git status"
