class_name InteractPrompt
extends Node2D

# Floats "[LMB] Attack" above whatever interactable currently has focus.
# Ported from trail-and-error.

# The primary interact action — the glyph fallback when a focused target
# carries no trigger of its own.
@export var interact_action: GUIDEAction

# How close to the viewport edge the prompt may sit, in world units.
@export var viewport_margin := 4.0

var _current: InteractionRegistration
var _formatter: GUIDEInputFormatter
var _key_text := ""

@onready var _service: InteractionService = Provider.inject(self, InteractionService)
@onready var _label: Label = %Label


func _ready() -> void:
	visible = false

	# The GUIDE input formatter renders the currently-bound input for an action
	# ("[LMB]" on keyboard/mouse, the button glyph on a pad) and tracks
	# context/device changes.
	_formatter = GUIDEInputFormatter.for_active_contexts()

	_service.focus_changed.connect(_on_focus_changed)
	_on_focus_changed(_service.focused)


func _exit_tree() -> void:
	if _service != null and _service.focus_changed.is_connected(_on_focus_changed):
		_service.focus_changed.disconnect(_on_focus_changed)


func _process(_delta: float) -> void:
	if _current == null:
		return

	# Re-apply every frame so a dynamic label reacts while focus is held. Label
	# BEFORE placement: the clamp needs this frame's width, and the width is
	# what a long label gets clamped for.
	if _apply_label(_current):
		_place(_current)


func _on_focus_changed(registration: InteractionRegistration) -> void:
	_current = registration

	if registration == null:
		visible = false
		return

	# Cache the input glyph on focus (it only changes on device/context switch,
	# which re-fires focus); the label itself is re-read each frame in _process.
	_key_text = _interact_key_text(registration)

	if _apply_label(registration):
		_place(registration)


func _interact_key_text(registration: InteractionRegistration) -> String:
	var action := registration.trigger if registration.trigger != null else interact_action

	if action == null or _formatter == null:
		return ""

	return _formatter.action_as_text(action)


func _apply_label(registration: InteractionRegistration) -> bool:
	# An interactable opts out of the prompt entirely by returning an empty
	# label; otherwise render "[input] <label>". Returns whether the prompt shows.
	var label_text := registration.get_label()

	if label_text.length() == 0:
		visible = false
		return false

	_label.text = ("%s %s" % [_key_text, label_text]) if _key_text.length() > 0 else label_text

	# Shrink the box onto the text. A fixed authored box lets a longer string
	# overflow invisibly — sized here, the rect is the truth the clamp below
	# can trust, and so can a scenario screenshot.
	var half := _label.get_minimum_size().x / 2.0
	_label.offset_left = -half
	_label.offset_right = half
	visible = true
	return true


func _place(registration: InteractionRegistration) -> void:
	# Sit at the target (plus its own prompt nudge), then pull back inside the
	# viewport if that would hang the text off an edge.
	var anchor := registration.get_position() + registration.prompt_offset
	var view := _visible_world_rect()
	var half := _label.size.x / 2.0

	# A label wider than the viewport cannot satisfy both edges; keep its START
	# readable rather than centering the overflow and losing both ends.
	var min_x := view.position.x + viewport_margin + half
	var max_x := view.end.x - viewport_margin - half
	var min_y := view.position.y + viewport_margin - _label.offset_top
	var max_y := view.end.y - viewport_margin - _label.offset_bottom

	global_position = Vector2(
		clampf(anchor.x, min_x, max_x) if max_x >= min_x else min_x,
		clampf(anchor.y, min_y, max_y) if max_y >= min_y else min_y
	)


func _visible_world_rect() -> Rect2:
	# The camera's visible rect in WORLD units, derived from the viewport
	# transform rather than the camera node — the prompt has no business knowing
	# which camera is live, and this follows zoom and limits for free.
	var screen := get_viewport().get_visible_rect()
	var to_world := get_viewport_transform().affine_inverse()
	var top_left := to_world * screen.position
	return Rect2(top_left, (to_world * screen.end) - top_left)
