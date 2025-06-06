extends Node

@onready var start: Button = %Start

@export var game_scene: PackedScene


func _ready() -> void:
	start.pressed.connect(_on_start_pressed)


func _on_start_pressed():
	Service.Screen.change_to_scene(game_scene)
