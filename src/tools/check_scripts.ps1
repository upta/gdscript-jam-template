# Project-wide GDScript compile gate: import, then load every script through a
# one-frame headless editor pass and fail on SCRIPT ERROR lines. This is the
# reliable whole-project check — per-file `--check-only` false-errors on
# anything referencing an autoload (godot#78587). The grep is the gate, not the
# exit code: the editor exits 0 even when scripts fail to compile.
param(
    [string]$GodotExe = $env:GODOT_EXE
)

$ErrorActionPreference = "Stop"

if (-not $GodotExe) {
    $command = Get-Command godot.exe -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        Write-Host "Could not locate godot.exe. Set GODOT_EXE or put Godot on PATH." -ForegroundColor Red
        exit 2
    }
    $GodotExe = $command.Source
}

# This script lives at src/tools/; the Godot project is its parent.
$projectPath = Split-Path -Parent $PSScriptRoot
$log = Join-Path $env:TEMP ("check_scripts_{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))

Write-Host "Importing..." -ForegroundColor Cyan
$import = Start-Process -FilePath $GodotExe -ArgumentList "--headless", "--import", "--path", $projectPath -Wait -PassThru -WindowStyle Hidden
if ($import.ExitCode -ne 0) {
    Write-Host "Import failed with exit code $($import.ExitCode)." -ForegroundColor Red
    exit 1
}

Write-Host "Compiling all scripts (1-frame editor pass)..." -ForegroundColor Cyan
$compile = Start-Process -FilePath $GodotExe -ArgumentList "--headless", "--editor", "--quit-after", "1", "--path", $projectPath, "--log-file", $log -Wait -PassThru -WindowStyle Hidden
if ($compile.ExitCode -ne 0) {
    Write-Host "Editor pass failed with exit code $($compile.ExitCode)." -ForegroundColor Red
    exit 1
}

$scriptErrors = @(Select-String -Path $log -Pattern "SCRIPT ERROR" -Context 0, 2 -ErrorAction SilentlyContinue)
if ($scriptErrors.Count -gt 0) {
    Write-Host ""
    Write-Host "Script errors found:" -ForegroundColor Red
    $scriptErrors | ForEach-Object { Write-Host $_.Line; $_.Context.PostContext | ForEach-Object { Write-Host "  $_" } }
    Write-Host ""
    Write-Host "Full log: $log"
    exit 1
}

Write-Host "All scripts compile clean." -ForegroundColor Green
exit 0
