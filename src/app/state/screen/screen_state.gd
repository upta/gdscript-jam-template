class_name ScreenState
extends Node

signal active_path_changed(old_path: String, new_path: String)

var active_path := "":
	get:
		return active_path

	set(value):
		var old = active_path
		active_path = value

		active_path_changed.emit(old, active_path)
