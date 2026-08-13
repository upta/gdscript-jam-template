---
name: validate-gameplay
description: Use for ANY change to gameplay code, or to reproduce a bug before fixing it — the red→green→suite→look loop, the harness rules, and the screenshot rubric.
---

# Validate gameplay

The test artifact in this repo is an in-engine validation scenario (D1):
JSON under `src/validation/scenarios/`, driving a harness scene, producing
numeric assertions AND screenshot evidence. Schema reference: the
author-validation-scenario skill. Reading failures: debug-validation-failure.

## The loop

1. **Red:** before (or alongside) implementing, write a scenario asserting the
   new behavior. Run it — it must FAIL, proving it tests something real.
2. **Green:** implement until the scenario passes.
3. **Suite:** `./validate.ps1` — the whole suite, no regressions.
   Flakiness check when timing changed: `./validate.ps1 -RepeatCount 3`.
4. **Look:** read the checkpoint screenshots (Read tool on the PNGs). Numeric
   assertions pass just fine while rendering is invisible or broken — your
   eyes are the last assertion.

Single scenario during iteration:

```powershell
pwsh tools/run_scenario.ps1 -Scenario validation/scenarios/<name>.json -ProjectPath src
```

Artifacts land at `src/artifacts/<scenario_id>/<timestamp>/` — `summary.json`
(`failed_assertion` has the step, observed value, and related screenshots),
`event_log.json`, `scene_tree.json`, `console.log`, `screenshots/*.png`.

## Screenshot review rubric

Reading the PNGs is the weakest verification step because a green run makes it
feel optional. It isn't: every numeric assertion in this repo can pass against
a scene that renders nothing. Answer these six, with specifics — a "looks
fine" with no specifics is a skipped review:

1. Is anything there at all?
2. Is the asserted subject actually in frame?
3. Do textures resolve (no blanks, no placeholder magenta)?
4. Did the frame change between checkpoints? Say WHICH pixels differ, not that
   they differ.
5. Does the picture agree with the number (bar length vs health value)?
6. Is anything stacked, clipped, or occluding?

Apply the same six to re-baselined pre-existing scenarios, not just new ones.

## Harness rules

Harnesses live in `src/validation/harnesses/` with controllers in
`src/validation/scripts/harness_controllers/`. A controller exposes
`get_observed_state() -> Dictionary` (semantic facts, not engine internals)
and `reset_harness()`, provides its own services via Provider, and enables the
mapping contexts it needs via `GUIDE.enable_mapping_context(...)`.

- **The runtime presses InputMap actions; GUIDE reads devices.** Bridge in
  `_physics_process`: watch `Input.is_action_pressed` edges for synthetic
  actions the harness registers itself (`InputMap.add_action`), and translate
  them into `GUIDE.inject_input(<real device event>)`.
- **Mouse position cannot be faked** (D6): GUIDE polls the OS cursor, and
  warping loses to a physical mouse. Harnesses own probe/cursor position
  directly; buttons and keys go through `GUIDE.inject_input`.
- **`wait_frames` is physics frames; there is no wait_seconds.** Anything with
  nondeterministic timing uses `wait_until` polling instead.
- A flaky scenario is a design smell — make it deterministic, never delete or
  loosen it to go green.
- The exemplar: `src/validation/scripts/harness_controllers/interaction_harness_controller.gd`.

## Exit codes

`0` pass · `1` assertion_failure · `2` runtime_error · `3` timeout ·
`4` artifact_generation_error. The runner prints `RESULT {json}` and
`ARTIFACTS <path>`.
