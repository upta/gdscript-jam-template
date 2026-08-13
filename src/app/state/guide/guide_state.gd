class_name GuideState
extends Node

signal input_mode_changed(input_mode: InputMode)
signal game_mode_changed(old_mode: String, new_mode: String)

enum InputMode {KBM, CONTROLLER}

# Set by GuideService each time mapping contexts change. Consumers (e.g.
# InteractTarget) ignore trigger edges raised in that same physics frame,
# because a context swap can hand actions back mid-frame and manufacture
# phantom presses. Static so harness scenes that run without a GuideService
# still resolve it (it just stays -1 there).
static var last_context_change_frame := -1

var active_game_mode := "":
	get:
		return active_game_mode

	set(value):
		if value != active_game_mode:
			var old := active_game_mode
			active_game_mode = value
			game_mode_changed.emit(old, active_game_mode)

var input_mode: InputMode = InputMode.KBM:
	get:
		return input_mode

	set(value):
		if value != input_mode:
			input_mode = value
			input_mode_changed.emit(input_mode)
