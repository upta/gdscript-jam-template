extends Node

## Composes a store cover out of captured stills: a plate of the game across the
## top, an optional second strip across the bottom, and the title and tagline in
## the space between. Game-agnostic — every colour, font and crop is a flag, so
## this file is the same in the template and in every project spawned from it.
##
## Stacked rather than cropped-and-titled, because a game is a 16:9 letterbox and
## the store wants something close to square: any single crop that fills 1260x1000
## shows a third of the screen, and the screen is the thing worth showing.
##
## godot --path src res://tools/presskit/cover.tscn --quit-after 900 -- \
##   --src <png> --art x,y,w,h [--strip_src <png>] [--strip x,y,w,h] \
##   [--size 1260x1000] [--title "..."] [--tagline "..."] \
##   [--ground #RRGGBB] [--accent #RRGGBB] [--ink #RRGGBB] [--ink_soft #RRGGBB] \
##   [--title_font res://... --body_font res://...] --out <png>

## Neutral enough to produce something legible with no palette passed, and wrong
## enough for every project to pass its own. Read them off the theme resource.
const GROUND := "#101216"
const INK := "#F2F4F8"
const INK_SOFT := "#8A8E9B"

## The rule under the art plate, and above the strip if there is one. Thin, and
## the one saturated thing on the cover apart from the game itself.
const RULE_HEIGHT := 5

var _args: Dictionary[String, String] = {}


func _ready() -> void:
	_args = _read_args()

	var size := _size()

	var art := _plate(_arg("src"), _arg("art"), size.x)
	if art == null:
		push_error("Cover needs --src and --art; got %s" % _args)
		get_tree().quit(1)
		return

	var strip := _plate(_arg("strip_src", _arg("src")), _arg("strip"), size.x)

	var viewport := SubViewport.new()
	viewport.size = size
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var ground := ColorRect.new()
	ground.color = _colour("ground", GROUND)
	ground.size = Vector2(size)
	viewport.add_child(ground)

	viewport.add_child(_pinned(art, 0.0))
	viewport.add_child(_rule(size.x, art.get_height()))

	var floor_y := float(size.y)
	if strip != null:
		floor_y -= strip.get_height()
		viewport.add_child(_pinned(strip, floor_y))
		viewport.add_child(_rule(size.x, roundi(floor_y) - RULE_HEIGHT))
		floor_y -= RULE_HEIGHT

	viewport.add_child(_type_block(size.x, art.get_height() + RULE_HEIGHT, floor_y))

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	var out := _out_path()
	viewport.get_texture().get_image().save_png(out)
	print("COVER_DONE ", out, " ", size)
	get_tree().quit()


## A relative --out resolves against the REPO, not the process working directory:
## `--path src` moves that directory out from under whoever typed the command, so
## `press/cover.png` would silently fail from the one place it obviously means.
func _out_path() -> String:
	var out := _arg("out", "cover.png")

	if out.is_absolute_path():
		return out

	return ProjectSettings.globalize_path("res://").path_join("..").path_join(out)


## One crop from one still, scaled to the cover's width. Lanczos rather than the
## nearest-neighbour an upscale would want: capture at 2x and this is always a
## reduction, and a reduction wants filtering. Pixel art is the exception — shoot
## it at 1x and swap this for INTERPOLATE_NEAREST.
func _plate(source_path: String, crop: String, width: int) -> Image:
	if source_path.is_empty() or crop.is_empty():
		return null

	var source := Image.load_from_file(source_path)
	if source == null:
		push_error("Cover source could not be read: %s" % source_path)
		return null

	var rect := _rect(crop, source)
	var cut := source.get_region(rect)
	var height := roundi(rect.size.y * (float(width) / float(rect.size.x)))

	cut.resize(width, height, Image.INTERPOLATE_LANCZOS)

	return cut


func _pinned(image: Image, top: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = ImageTexture.create_from_image(image)
	rect.position = Vector2(0.0, top)
	rect.size = Vector2(image.get_width(), image.get_height())

	return rect


func _rule(width: int, top: int) -> ColorRect:
	var rule := ColorRect.new()
	rule.color = _colour("accent", _arg("ink_soft", INK_SOFT))
	rule.position = Vector2(0.0, top)
	rule.size = Vector2(width, RULE_HEIGHT)

	return rule


## The name and the promise, centred in whatever the plates left behind.
func _type_block(width: int, top: float, bottom: float) -> Control:
	var lines := VBoxContainer.new()
	lines.position = Vector2(0.0, top)
	lines.size = Vector2(width, bottom - top)
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", int(_arg("separation", "14")))

	lines.add_child(
		_line(
			_arg("title", ProjectSettings.get_setting("application/config/name", "")),
			_arg("title_font"),
			int(_arg("title_size", "104")),
			_colour("ink", INK)
		)
	)

	var tagline := _arg("tagline")
	if not tagline.is_empty():
		lines.add_child(
			_line(
				tagline,
				_arg("body_font"),
				int(_arg("tagline_size", "30")),
				_colour("ink_soft", INK_SOFT)
			)
		)

	return lines


## No font given means the project theme's, which is what the game itself would
## have used. A path that does not resolve is skipped rather than fatal — a cover
## in the wrong face still shows you the crop was wrong.
func _line(text: String, font_path: String, size: int, colour: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", colour)

	if not font_path.is_empty() and ResourceLoader.exists(font_path):
		label.add_theme_font_override("font", load(font_path))

	return label


func _colour(key: String, fallback: String) -> Color:
	return Color.from_string(_arg(key, fallback), Color.from_string(fallback, Color.WHITE))


func _size() -> Vector2i:
	var parts := _arg("size", "1260x1000").split("x")

	if parts.size() != 2:
		return Vector2i(1260, 1000)

	return Vector2i(int(parts[0]), int(parts[1]))


func _rect(raw: String, source: Image) -> Rect2i:
	var parts := raw.split(",")

	if parts.size() != 4:
		push_error("a crop wants x,y,w,h — got %s" % raw)
		return Rect2i(Vector2i.ZERO, source.get_size())

	return Rect2i(int(parts[0]), int(parts[1]), int(parts[2]), int(parts[3]))


## Typed lookup. Dictionary.get() hands back a Variant even out of a typed
## dictionary, and a Variant cannot be split, measured, or passed to a String
## parameter without the parser giving up on inferring anything downstream.
func _arg(key: String, fallback: String = "") -> String:
	return _args[key] if _args.has(key) else fallback


## Flags are --key value, or --key on its own for a switch. A value runs to the
## next flag rather than to the next space: a title and a tagline are sentences,
## and PowerShell hands a quoted argument through to a process unquoted, so
## "--title NEW CLEARUN" is what actually arrives however carefully it was typed.
func _read_args() -> Dictionary[String, String]:
	var found: Dictionary[String, String] = {}
	var argv := OS.get_cmdline_user_args()
	var key := ""
	var value: PackedStringArray = []

	for token: String in argv:
		if token.begins_with("--"):
			if not key.is_empty():
				found[key] = " ".join(value)

			key = token.substr(2)
			value = []
		elif not key.is_empty():
			value.append(token)

	if not key.is_empty():
		found[key] = " ".join(value)

	return found
