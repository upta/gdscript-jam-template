# The repo's validation gate: the full pure scenario suite, parallel with a
# serial re-run of failures. This project has no SpacetimeDB tier, and the
# kit's validate_all.ps1 assumes one (it stands up a local server before
# noticing there are no scenarios_stdb) — so the gate calls the pure-suite
# runner directly. Requires PowerShell 7 (the runner fans out with
# ForEach-Object -Parallel).
#
#   ./validate.ps1                  # the Definition-of-Done gate
#   ./validate.ps1 -RepeatCount 3   # flakiness check
param(
    [int]$RepeatCount = 1,
    [string]$GodotExe = $env:GODOT_EXE
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$runner = Join-Path $root "tools/run_all_scenarios.ps1"

$runnerArgs = @("-ProjectPath", (Join-Path $root "src"), "-RepeatCount", $RepeatCount)
if ($GodotExe) { $runnerArgs += @("-GodotExe", $GodotExe) }

& pwsh -NoProfile -File $runner @runnerArgs
exit $LASTEXITCODE
