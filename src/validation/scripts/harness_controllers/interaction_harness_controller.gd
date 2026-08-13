extends Node2D

# Deterministic interaction scene: two characters, a probe, and the interact
# prompt — without the app/screen stack. The validation runtime presses
# InputMap actions; _physics_process bridges their edges onto the systems under
# test (pattern from nomad's InteractionHarnessController).
#
# The probe position is harness-owned rather than GUIDE-cursor-driven, on
# purpose: GUIDE polls the OS cursor for mouse POSITION
# (guide_input_state.get_mouse_position -> viewport poll), so no injected event
# can fake it, and Input.warp_mouse loses to any physical mouse twitch — both
# were tried and produced flaky runs. Substituting the position source keeps
# everything under test (targets, service focus, prompt, GUIDE action
# triggers) on its real path: attack/heal still fire through real GUIDE mouse
# BUTTON events, which are event-fed and injectable.

const GAME_KBM_CONTEXT := preload("res://guide/game/game_kbm_context.tres")

const _MOUSE_BUTTONS: Dictionary[String, MouseButton] = {
	"attack": MOUSE_BUTTON_LEFT,
	"heal": MOUSE_BUTTON_RIGHT,
}

const _AIM_AWAY_POINT := Vector2(120.0, 560.0)

var interaction_service := InteractionService.new()

var _virtual_cursor := _AIM_AWAY_POINT
var _aim_points: Dictionary[String, Callable] = {}
var _bridge_state: Dictionary[String, bool] = {}

@onready var character_a: Node2D = %CharacterA
@onready var character_b: Node2D = %CharacterB
@onready var probe: InteractProbe = %InteractProbe
@onready var prompt: InteractPrompt = %InteractPrompt


func _enter_tree() -> void:
	Provider.provide(self, interaction_service)


func _ready() -> void:
	_aim_points = {
		"aim_character_a": func() -> Vector2: return character_a.global_position,
		"aim_character_b": func() -> Vector2: return character_b.global_position,
		"aim_away": func() -> Vector2: return _AIM_AWAY_POINT,
	}

	for action_name: String in _aim_points.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

	for action_name: String in _MOUSE_BUTTONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

	GUIDE.enable_mapping_context(GAME_KBM_CONTEXT)


func _physics_process(_delta: float) -> void:
	_bridge_actions()

	probe.global_position = _virtual_cursor

	interaction_service.update_probe_data(ProbeData.new(_virtual_cursor))
	interaction_service.process()


func reset_harness() -> void:
	character_a.health.current_health = character_a.health.max_health
	character_b.health.current_health = character_b.health.max_health

	_bridge_state.clear()
	_virtual_cursor = _AIM_AWAY_POINT


func get_observed_state() -> Dictionary:
	return {
		"health": {
			"a": character_a.health.current_health,
			"b": character_b.health.current_health,
		},
		"interaction": {
			"focused_exists": interaction_service.focused != null,
			"focused_label": "" if interaction_service.focused == null else interaction_service.focused.get_label(),
			"registration_count": interaction_service.get_registrations().size(),
			"prompt_visible": prompt.visible,
		},
		"cursor": {
			"x": _virtual_cursor.x,
			"y": _virtual_cursor.y,
		},
	}


func _bridge_actions() -> void:
	for action_name: String in _aim_points.keys():
		if _edge(action_name) == 1:
			_virtual_cursor = _aim_points[action_name].call()

	for action_name: String in _MOUSE_BUTTONS.keys():
		var edge := _edge(action_name)

		if edge == 0:
			continue

		# Straight into GUIDE's ingestion API: immune to window focus and to any
		# Control's mouse_filter on the way to _unhandled_input.
		var event := InputEventMouseButton.new()
		event.button_index = _MOUSE_BUTTONS[action_name]
		event.pressed = edge == 1
		event.position = _virtual_cursor
		event.global_position = _virtual_cursor
		GUIDE.inject_input(event)


func _edge(action_name: String) -> int:
	# +1 on the press edge, -1 on the release edge, 0 when unchanged since the
	# last physics frame.
	var pressed := Input.is_action_pressed(action_name)
	var was: bool = _bridge_state.get(action_name, false)

	if pressed == was:
		return 0

	_bridge_state[action_name] = pressed
	return 1 if pressed else -1
