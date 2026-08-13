# Export the Web preset and PROVE it produced a build. The exit code is not
# the check: godot --export-release exits 0 on an unknown preset having
# written nothing - the files' existence and size are the check.
param(
    [string]$GodotExe = $env:GODOT_EXE,
    [string]$OutDir = ""
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

# This script lives at src/tools/; the Godot project is its parent, the repo
# root above that.
$projectPath = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $projectPath
if (-not $OutDir) { $OutDir = Join-Path $repoRoot "build\web" }

if (Test-Path $OutDir) { Remove-Item -Recurse -Force $OutDir }
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host "Exporting Web preset to $OutDir..." -ForegroundColor Cyan
$indexPath = Join-Path $OutDir "index.html"
$p = Start-Process -FilePath $GodotExe -ArgumentList "--headless", "--path", $projectPath, "--export-release", "Web", $indexPath -Wait -PassThru -WindowStyle Hidden
Write-Host "godot exit code: $($p.ExitCode) (informational - the files below are the check)"

$required = @("index.html", "index.pck", "index.wasm")
$missing = @()
foreach ($name in $required) {
    $path = Join-Path $OutDir $name
    if (-not (Test-Path $path) -or (Get-Item $path).Length -eq 0) { $missing += $name }
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Export did NOT produce a build. Missing or empty: $($missing -join ', ')" -ForegroundColor Red
    $templates = Join-Path $env:APPDATA "Godot\export_templates"
    if (-not (Test-Path (Join-Path $templates "4.7.1.stable"))) {
        Write-Host "Likely cause: export templates are not installed ($templates\4.7.1.stable is absent)." -ForegroundColor Yellow
        Write-Host "One-time install: download Godot_v4.7.1-stable_export_templates.tpz from the Godot" -ForegroundColor Yellow
        Write-Host "4.7.1 release page and extract its templates/ contents into that folder." -ForegroundColor Yellow
    }
    exit 1
}

Write-Host ""
Get-ChildItem $OutDir | ForEach-Object { Write-Host ("  {0,12:n0} bytes  {1}" -f $_.Length, $_.Name) }
Write-Host ""
Write-Host "Web build ready. Serve it with: powershell src/tools/serve_web.ps1" -ForegroundColor Green
exit 0
