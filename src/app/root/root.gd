extends Node

@export var main_menu_scene: PackedScene


func _ready() -> void:
	Service.Screen.change_to_scene(main_menu_scene)
