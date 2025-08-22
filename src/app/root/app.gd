extends Node

@export var main_menu_scene: PackedScene
@onready var screen_service: ScreenService = Provider.inject(self, ScreenService)

@onready var settings_manager: SettingsManager = $SettingsManager


func _ready() -> void:
	Provider.provide(self, settings_manager)
	
	screen_service.change_to_scene(main_menu_scene)
