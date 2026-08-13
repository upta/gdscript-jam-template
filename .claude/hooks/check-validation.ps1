# Stop hook: block ending the turn when gameplay code changed but no
# validation run is newer than the change. Freshness only - proving GREEN is
# the Definition of Done's job (CLAUDE.md).
$hookInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($hookInput.stop_hook_active) { exit 0 }

$repo = git rev-parse --show-toplevel 2>$null
if (-not $repo) { exit 0 }
Set-Location $repo

# Working-tree changes to game code, with the vendored/generated trees cut out.
$changed = @(git status --porcelain -- 'src' ':(exclude)src/addons' ':(exclude)src/artifacts' ':(exclude)src/tools' |
        ForEach-Object { $_.Substring(3).Trim('"') })
if ($changed.Count -eq 0) { exit 0 }

# Newest mtime among the changes. Entries that no longer exist on disk
# (deletions, rename sources) count as "changed right now": a deletion
# deserves a validation run too, and a missing mtime must fail toward
# blocking, not toward passing.
$newestChange = Get-Date '2000-01-01'
foreach ($path in $changed) {
    if (Test-Path $path) {
        $mtime = (Get-Item $path -Force).LastWriteTime
        if ($mtime -gt $newestChange) { $newestChange = $mtime }
    } else {
        $newestChange = Get-Date
        break
    }
}

$newestRun = Get-ChildItem 'src/artifacts' -Recurse -Filter 'summary.json' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $newestRun -or $newestChange -gt $newestRun.LastWriteTime) {
    @{ decision = 'block'; reason = 'Gameplay code changed since the last validation run. Run ./validate.ps1 (or a targeted tools/run_scenario.ps1) and review the screenshots before ending the turn (validate-gameplay skill).' } | ConvertTo-Json -Compress
}
exit 0
