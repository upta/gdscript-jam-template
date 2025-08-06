extends Node

@export var main_menu_scene: PackedScene

@onready var screen_service: ScreenService = Provider.inject(self, ScreenService)


func _ready() -> void:
	screen_service.change_to_scene(main_menu_scene)
