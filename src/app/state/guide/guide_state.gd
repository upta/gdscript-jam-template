class_name GuideState
extends Node

signal input_mode_changed(input_mode)
signal game_mode_changed(old_mode, new_mode)

enum InputMode {KBM, CONTROLLER}

var active_game_mode := "":
	get:
		return active_game_mode

	set(value):
		if value != active_game_mode:
			var old = active_game_mode
			active_game_mode = value
			game_mode_changed.emit(old, active_game_mode)

var input_mode: InputMode = InputMode.KBM:
	get:
		return input_mode

	set(value):
		if value != input_mode:
			input_mode = value
			input_mode_changed.emit(input_mode)
