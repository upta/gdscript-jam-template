---
name: press-kit
description: Use when the itch.io page needs art — a cover image, screenshots, a banner, or theme colours — captured out of the running game rather than mocked up or cropped by hand.
---

# Press kit

The store page is the only part of a jam entry most people ever see, and every
pixel of it has to come out of the game. Two tools, both under
`src/tools/presskit/`: a capture tool you write per game, and `cover.gd`, which
is generic and already here. Output lands in `press/`, which is generated —
never hand-edited, always rebuildable.

## What the page asks for

| Field | Size | Notes |
| --- | --- | --- |
| Cover image | 630x500 recommended, 315x250 minimum | Ship 1260x1000 and let itch scale it down. The one asset a browsing player sees before anything else. |
| Screenshots | 3–5, any size | Ship the native capture. One per *decision the game asks you to make*, not one per screen. |
| Banner / page background | optional | Usually leave empty. A busy image behind a dark page fights the screenshots. |
| Colour, font, layout | — | `press/THEME.md`, below. |

## 1. Capture

Write `src/tools/presskit/presskit.gd` + `.tscn` for this game. Non-negotiables,
each of which is a bug somebody has already shipped:

- **Boot `root.tscn`, never the gameplay scene.** Screens inject services
  through Provider; standalone they come up half-wired and render wrong in ways
  that are not obvious in a still.
- **Drive the real controls.** Press the same signals a click emits
  (`press_roll()`, a button's `pressed.emit()`), never the state underneath.
  A still that shows a position the game cannot reach is a lie on a store page.
- **`--scale 2`.** Switch the window to `CONTENT_SCALE_MODE_CANVAS_ITEMS` at the
  design size and double the window: Controls re-rasterise their type at the
  larger size. The project's own `viewport` stretch mode would upscale a
  1280x720 texture instead, which is blurrier, not sharper. The window may
  exceed the display — the render target is still full size. **Pixel art is the
  exception: shoot at 1x and upscale by an integer with NEAREST.**
- **Plan in moments, not seconds** for a turn-based game — a wall-clock cue
  lands mid-animation on one machine and mid-round on the next. Real-time games
  invert this: a seconds table is the only thing that can catch a boss
  mid-sentence.
- **Bound the run.** A stand-in never gets bored; a wedged game would leave the
  process up until somebody noticed.
- **Mute the master bus.** A capture run renders faster than anyone can listen
  to it.
- **Skip the opening round.** Everyone starts on the same edge, so the first
  round is every token in a stack next to an empty screen. Gate the early
  moments on a round or level counter.

The shape:

```gdscript
const PLAN: Dictionary[String, int] = {"menu": 2, "push": 4, "bust": 2}
const EARLIEST: Dictionary[String, int] = {"push": 3, "bust": 2}
const DESIGN := Vector2i(1280, 720)

func _ready() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	if _scale > 1:
		var window := get_window()
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
		window.content_scale_size = DESIGN
		window.size = DESIGN * _scale
	add_child(load("res://app/root/root.tscn").instantiate())
	var screen := await _await_node("MenuFront")   # search the tree; the screen
	...                                            # manager adds it a few frames late

func _shoot(moment: String) -> void:
	var kept: int = _taken.get(moment, 0)
	if kept >= PLAN.get(moment, 0) or _too_early(moment):
		return
	_taken[moment] = kept + 1
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw          # twice: once is a stale frame
	get_viewport().get_texture().get_image().save_png(
		_out_dir.path_join("%02d_%s_%d.png" % [_index, moment, kept + 1])
	)
```

Name files by moment, not by beat, so a re-shoot drops the same shots in the
same slots and the page's filenames do not move underneath it. Loop the game
back to its restart control when the plan is not yet full — a bust needs a push
that fails and a first place needs a race that goes well, and neither is
something to arrange.

```powershell
Start-Process godot -Wait -ArgumentList "--path","src",
  "res://tools/presskit/presskit.tscn","--","--out","<abs dir>","--scale","2"
```

Then **look at every still** and pick. Choose by decision shown, not by prettiness:
two shots of the same board a second apart read as one duplicated screenshot.

## 2. Cover

A game is 16:9 and the cover is 1.26:1, so no single crop fills it without
throwing away two thirds of the screen. `cover.gd` stacks instead: an art plate
across the top, an optional second strip across the bottom, and the title in the
ground between them.

```powershell
Start-Process godot -Wait -ArgumentList "--path","src",
  "res://tools/presskit/cover.tscn","--quit-after","900","--",
  "--src","<dir>\<still>.png","--art","<x,y,w,h>",
  "--strip_src","<dir>\<other>.png","--strip","<x,y,w,h>","--strip_pad","30",
  "--title","<NAME>","--title_size","108",
  "--ground","<#hex>","--accent","<#hex>","--ink","<#hex>","--ink_soft","<#hex>",
  "--out","press/cover.png"
```

It carries no palette of its own — pass every colour from the theme, which is
what lets the same file sit in the template and in every project spawned from
it. `--title_font` / `--body_font` are optional and default to the project
theme's face; give them when the game ships its own.

- **Title only. No tagline, subheading, or second line unless the person asking
  for the cover asks for one** — `--tagline` exists for that request and for
  nothing else. A cover is read at thumbnail size, where a second line is
  noise, and the page already has a description field for the sentence.
- **Pick the art crop so every player character is inside it.** A cover missing
  one of four racers reads as an accident rather than a crop.
- **Compose the title fresh rather than cropping the menu's.** A
  shader-animated title is a different picture every frame, and the cover has to
  hold up as a thumbnail.
- **`--strip_pad` lifts the lower rule off the strip.** A crop is tight to its
  own contents, so a rule laid straight on it reads as a lid on the dice. Set
  `--ground` to the colour the game draws *behind* that strip and the margin
  flows into it instead of stepping into it.

## 3. Theme colours

Read them off `src/app/theme/default_theme.tres` and whatever else holds
colour (tiles, dice, racer tints) — never sample them out of a PNG, which
picks up whatever was blended over them. Godot floats convert with
`round(v * 255)`.

Offer two palettes, both drawn from the game, and say which one is
recommended and why. Every text pair must clear WCAG AA (4.5:1); print the
number rather than asserting it:

```powershell
function Get-Lum($h){ $c = 1..3 | ForEach-Object { $v = [Convert]::ToInt32($h.Substring(($_*2)-1,2),16)/255; if($v -le 0.03928){ $v/12.92 } else { [Math]::Pow(($v+0.055)/1.055,2.4) } }; 0.2126*$c[0] + 0.7152*$c[1] + 0.0722*$c[2] }
function Get-Contrast($a,$b){ $x = Get-Lum $a; $y = Get-Lum $b; if($x -lt $y){ $t=$x; $x=$y; $y=$t }; [Math]::Round(($x+0.05)/($y+0.05),1) }
Get-Contrast '#F1F4FA' '#16181F'
```

Do not offer a light palette for a dark game just to have two: it makes every
screenshot look like a hole punched in the page. Two variants of the right
brightness beat one right and one polite.

## 4. `press/THEME.md`

The handover document. It must carry: the commands that rebuild every file
(crops included — they are the only hand-chosen numbers), a table of what each
file is and which field it goes in, the palettes with their contrast numbers
and what each colour is *in the game*, the font and embed-background calls, and
the raw palette as source of truth for rebuilding either table.

Add rows to ARCHITECTURE.md's codemap for `press/` and the presskit tools.

## Traps

- **PowerShell `-ArgumentList` does not quote.** `"--title","NEW CLEARUN"`
  arrives as two tokens. Both tools read a flag's value up to the next `--`,
  which is why that works — keep it that way in anything you add.
- **A parse error in the tool's script leaves a window that never quits**, and
  `Start-Process -Wait` blocks forever on it. Always pass `--quit-after`.
- **`godot.exe` is GUI-subsystem:** `-Wait` is load-bearing or the command
  returns before a single frame is drawn.
- **A relative `--out` is relative to `--path src`, not to the repo.** `cover.gd`
  resolves relative paths against the repo root for this reason; anything new
  should too.
- These tools assert nothing and are **not** validation harnesses. The
  validation Stop hook excludes `src/tools`, so a press kit does not need a
  scenario — but it does need the compile gate and `.uid` sidecars like
  anything else.
