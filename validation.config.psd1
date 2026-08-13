# Configuration for the validation runners (tools/*.ps1, from the agentic-godot-validation kit).
# Every knob has a convention default; this file overrides for this repo's layout: the Godot
# project lives under src/, which the kit's auto-detection (repo root or client/) doesn't find.
@{
    AppName       = 'jam-game' # rename with the project; derives artifact/token naming
    ClientRoot    = 'src'
    ArtifactsRoot = 'src/artifacts' # keep in lockstep with run_scenario.ps1, which writes to <project>/artifacts
}
