extends Node

@onready var audio_service: AudioService = Provider.inject(self, AudioService)
@onready var guide_service: GuideService = Provider.inject(self, GuideService)
@onready var screen_service: ScreenService = Provider.inject(self, ScreenService)
@onready var settings_manager: SettingsManager = Provider.inject(self, SettingsManager)

@export var game_scene: PackedScene
@export var settings_action: GUIDEAction

@onready var start: Button = %Start
@onready var settings: Button = %Settings


func _ready() -> void:
	guide_service.set_game_mode("main_menu")

	start.pressed.connect(_on_start_pressed)
	settings.pressed.connect(_on_settings_pressed)
	settings_action.triggered.connect(_on_settings_pressed)

	audio_service.play_music(Audio.music.menu)
	

func _on_start_pressed():
	screen_service.change_to_scene(game_scene)


func _on_settings_pressed():
	settings_manager.toggle()
