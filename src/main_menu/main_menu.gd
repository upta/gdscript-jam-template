extends Node

@onready var start: Button = %Start
@onready var settings: Button = %Settings

@export var game_scene: PackedScene
@export var settings_action: GUIDEAction


func _ready() -> void:
	State.Guide.active_game_mode = "main_menu"

	start.pressed.connect(_on_start_pressed)
	settings.pressed.connect(_on_settings_pressed)
	settings_action.triggered.connect(_on_settings_pressed)


func _on_start_pressed():
	Service.Screen.change_to_scene(game_scene)


func _on_settings_pressed():
	prints("show settings")
