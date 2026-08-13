extends Node

@export var settings_action: GUIDEAction
@export var cursor_action: GUIDEAction

var interaction_service := InteractionService.new()

@onready var guide_service: GuideService = Provider.inject(self, GuideService)
@onready var settings_manager: SettingsManager = Provider.inject(self, SettingsManager)
@onready var probe: InteractProbe = %InteractProbe


func _enter_tree() -> void:
	Provider.provide(self, interaction_service)


func _ready() -> void:
	guide_service.set_game_mode("game")

	settings_action.triggered.connect(_on_settings_action_triggered)


func _physics_process(_delta: float) -> void:
	# The demo probe follows the cursor; a player-driven game would child the
	# probe under the player and feed its position (and facing) here instead.
	var cursor_pos: Vector2 = cursor_action.value_axis_2d
	probe.global_position = cursor_pos

	interaction_service.update_probe_data(ProbeData.new(cursor_pos))
	interaction_service.process()


func _on_settings_action_triggered() -> void:
	settings_manager.toggle()
