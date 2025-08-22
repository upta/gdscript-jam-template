class_name GuideService
extends Node

@onready var context: InputContext = Provider.inject(self, InputContext)
@onready var state: GuideState = Provider.inject(self, GuideState)


func _ready() -> void:
	if context.switch_to_controller_action:
		var controller_mode = GuideState.InputMode.CONTROLLER
		context.switch_to_controller_action.triggered.connect(_set_input_mode.bind(controller_mode))

	if context.switch_to_kbm_action:
		var kbm_mode = GuideState.InputMode.KBM
		context.switch_to_kbm_action.triggered.connect(_set_input_mode.bind(kbm_mode))

	state.game_mode_changed.connect(_on_game_mode_changed)
	state.input_mode_changed.connect(_on_input_mode_changed)

	_update_input()


func set_game_mode(mode: String) -> void:
	var mode_exists = false

	for mode_context in context.input_mode_contexts:
		if mode_context.game_mode == mode:
			mode_exists = true
			break

	if !mode_exists:
		push_error("Cannot set game mode '%s' as it doesn't exist in the contexts array" % mode)
		return

	state.active_game_mode = mode


func _on_game_mode_changed(_old_mode: String, _new_mode: String) -> void:
	_update_input()


func _on_input_mode_changed(_input_mode: GuideState.InputMode) -> void:
	_update_input()


func _set_input_mode(mode: GuideState.InputMode) -> void:
	state.input_mode = mode


func _update_input() -> void:
	var active_game_mode = state.active_game_mode

	if active_game_mode.is_empty():
		return

	var game_mode_context = null

	for mode_context in context.input_mode_contexts:
		if mode_context.game_mode == active_game_mode:
			game_mode_context = mode_context
			break

	if game_mode_context == null:
		var error_message = "No context found for game mode '%s'"
		push_error(error_message % active_game_mode)
		return

	match state.input_mode:
		GuideState.InputMode.KBM:
			if context.global_kbm_context != null:
				GUIDE.enable_mapping_context(context.global_kbm_context, true)
			else:
				push_error("Global KBM context is null")

			if game_mode_context.kbm_context != null:
				GUIDE.enable_mapping_context(game_mode_context.kbm_context)
			else:
				var warning_message = "KBM context for game mode '%s' is null"
				push_warning(warning_message % active_game_mode)

		GuideState.InputMode.CONTROLLER:
			if context.global_controller_context != null:
				GUIDE.enable_mapping_context(context.global_controller_context, true)
			else:
				push_error("Global controller context is null")

			if game_mode_context.controller_context != null:
				GUIDE.enable_mapping_context(game_mode_context.controller_context)
			else:
				var warning_message = "Controller context for game mode '%s' is null"
				push_warning(warning_message % active_game_mode)
