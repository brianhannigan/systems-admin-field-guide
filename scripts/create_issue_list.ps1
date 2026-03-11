# Creates a local backlog file you can paste into GitHub issues later.
$issues = @(
    '[Chapter] Expand First 30 Days Survival Plan',
    '[Chapter] Expand Red Hat Linux Admin Skills',
    '[Chapter] Expand Terraform Learning Path',
    '[Chapter] Expand Azure Infrastructure Skills',
    '[Chapter] Expand STIG Hardening Guide',
    '[Chapter] Expand Server Upgrade Strategy',
    '[Chapter] Expand Vulnerability Management Workflow',
    '[Lab] Create single-VM Linux service failure lab',
    '[Lab] Create single-VM Terraform Azure deployment lab',
    '[Script] Add Bash health-check starter pack'
)

$issues | Set-Content -Path .\ISSUE_BACKLOG.txt
Write-Host 'Created ISSUE_BACKLOG.txt'
