# Stop hook: documentation line budgets. The budget is an argument, not a
# wall: if the growth is legitimate, raise the budget HERE in the same commit
# and say why in the commit message. Every raise leaves a trail.
$hookInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($hookInput.stop_hook_active) { exit 0 }

$repo = git rev-parse --show-toplevel 2>$null
if (-not $repo) { exit 0 }
Set-Location $repo

$problems = @()

# Whole-file budgets.
$fileBudgets = @{
    'CLAUDE.md'       = 130
    'ARCHITECTURE.md' = 120
    'SPEC.md'         = 70
}
foreach ($file in $fileBudgets.Keys) {
    if (-not (Test-Path $file)) { continue }
    $count = @(Get-Content $file).Count
    if ($count -gt $fileBudgets[$file]) {
        $problems += "$file is $count lines (budget $($fileBudgets[$file]))."
    }
}

# DECISIONS.md: only the Active section is budgeted; Closed is append-only and
# ungated. Measured off the section headings, and a missing or out-of-order
# marker BLOCKS rather than passing - rename the heading and a lenient gate
# silently stops gating, which is worse than the budget itself.
$decisionsActiveBudget = 90
if (Test-Path 'DECISIONS.md') {
    $lines = @(Get-Content 'DECISIONS.md')
    $activeIdx = [Array]::IndexOf($lines, '## Active')
    $closedIdx = [Array]::IndexOf($lines, '## Closed')
    if ($activeIdx -lt 0 -or $closedIdx -lt 0 -or $closedIdx -lt $activeIdx) {
        $problems += "DECISIONS.md is missing its '## Active' / '## Closed' markers (or they are out of order), so the budget gate cannot measure it."
    } else {
        $activeCount = $closedIdx - $activeIdx
        if ($activeCount -gt $decisionsActiveBudget) {
            $problems += "DECISIONS.md Active section is $activeCount lines (budget $decisionsActiveBudget); absorb or supersede old decisions into Closed."
        }
    }
}

# tasks/: one phase ticket at a time, and a whole-tree budget.
$tasksTreeBudget = 100
if (Test-Path 'tasks') {
    $phaseTickets = @(Get-ChildItem 'tasks' -Filter 'phase-*.md')
    if ($phaseTickets.Count -gt 1) {
        $names = ($phaseTickets | ForEach-Object { $_.Name }) -join ', '
        $problems += "tasks/ has $($phaseTickets.Count) phase tickets ($names); a closed phase's ticket is deleted, not archived."
    }
    $treeLines = 0
    Get-ChildItem 'tasks' -Filter '*.md' | ForEach-Object { $treeLines += @(Get-Content $_.FullName).Count }
    if ($treeLines -gt $tasksTreeBudget) {
        $problems += "tasks/ tree is $treeLines lines total (budget $tasksTreeBudget)."
    }
}

if ($problems.Count -gt 0) {
    $reason = 'Documentation budgets: ' + ($problems -join ' ') + ' If the growth is legitimate, raise the budget in .claude/hooks/check-docs.ps1 in the same commit and say why.'
    @{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress
}
exit 0
