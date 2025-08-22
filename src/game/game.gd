extends Node

@onready var guide_service: GuideService = Provider.inject(self, GuideService)
@onready var settings_manager: SettingsManager = Provider.inject(self, SettingsManager)

@export var settings_action: GUIDEAction


func _ready() -> void:
	guide_service.set_game_mode("game")

	settings_action.triggered.connect(_on_settings_action_triggered)


func _on_settings_action_triggered():
	settings_manager.toggle()
