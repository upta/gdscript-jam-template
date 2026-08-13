# Jam dev loop: pick a branch (when origin has more than main), pull, import
# assets, then run the game windowed.
param(
    # Bypass the interactive picker (agents, scripts, CI): switch straight to
    # this branch. The console picker reads EOF in a non-interactive shell.
    [string]$Branch = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

function Select-FromList {
    param([string[]]$Options, [int]$DefaultIndex)

    $index = $DefaultIndex
    $top = [Console]::CursorTop

    while ($true) {
        [Console]::SetCursorPosition(0, $top)
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $marker = if ($i -eq $index) { ">" } else { " " }
            $color = if ($i -eq $index) { "Cyan" } else { "Gray" }
            $line = "{0} {1}" -f $marker, $Options[$i]
            Write-Host $line.PadRight([Console]::WindowWidth - 1) -ForegroundColor $color
        }

        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" { $index = ($index - 1 + $Options.Count) % $Options.Count }
            "DownArrow" { $index = ($index + 1) % $Options.Count }
            "Enter" { return $Options[$index] }
            "Escape" { return $Options[$DefaultIndex] }
        }
    }
}

Write-Host "Fetching origin..." -ForegroundColor Cyan
# --prune, or the picker offers branches that no longer exist on origin.
git fetch --prune origin
if ($LASTEXITCODE -ne 0) { exit 1 }

$current = git branch --show-current
$remoteBranches = @(git branch -r --format="%(refname:short)" |
        Where-Object { $_ -notmatch "HEAD" } |
        ForEach-Object { $_ -replace "^origin/", "" })

$targetBranch = $current
if ($Branch) {
    $targetBranch = $Branch
} elseif (@($remoteBranches | Where-Object { $_ -ne "main" }).Count -gt 0 -and -not [Console]::IsInputRedirected) {
    # Current branch first, so plain Enter means "stay here".
    $options = @($current) + @($remoteBranches | Where-Object { $_ -ne $current } | Sort-Object)
    Write-Host ""
    Write-Host "Branch (arrows to move, Enter to select):" -ForegroundColor Cyan
    $targetBranch = Select-FromList -Options $options -DefaultIndex 0
}

if ($targetBranch -ne $current) {
    Write-Host ""
    Write-Host "Switching to $targetBranch..." -ForegroundColor Cyan
    # A dirty tree fails the switch loudly — commit or stash yourself, no silent
    # stashing here. git switch auto-creates a tracking branch for remote ones.
    git switch $targetBranch
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

Write-Host ""
Write-Host "Pulling latest..." -ForegroundColor Cyan
git pull
if ($LASTEXITCODE -ne 0) { exit 1 }

$godotExe = if ($env:GODOT_EXE) { $env:GODOT_EXE } else { (Get-Command godot.exe -ErrorAction Stop).Source }

Write-Host ""
Write-Host "Importing assets..." -ForegroundColor Cyan
# Re-import EVERY run, not just first-run: a real-game boot doesn't auto-import,
# so a pulled asset change leaves the .godot cache stale and sprites render
# blank. Start-Process -Wait is load-bearing: godot.exe is a GUI-subsystem
# binary, so a bare invocation returns immediately and the game below would
# launch while the import still runs — pulled assets then only show up on the
# NEXT run (the bug this script exists to avoid).
$import = Start-Process -FilePath $godotExe -ArgumentList "--headless", "--import", "--path", "src" -Wait -PassThru -WindowStyle Hidden
if ($import.ExitCode -ne 0) {
    Write-Host "Godot import failed with exit code $($import.ExitCode)." -ForegroundColor Red
    exit $import.ExitCode
}

Write-Host ""
Write-Host "Running..." -ForegroundColor Cyan
# Deliberately NOT waited on: the script hands off to the game window.
Start-Process -FilePath $godotExe -ArgumentList "--path", "src" | Out-Null
