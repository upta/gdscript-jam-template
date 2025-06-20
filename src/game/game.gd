extends Node

@export var settings_action: GUIDEAction


func _ready() -> void:
	State.Guide.active_game_mode = "game"
	settings_action.triggered.connect(_on_settings_action_triggered)


func _on_settings_action_triggered():
	prints("show settings... game!")
