class_name GuideService
extends Node

@export var input_mode_contexts: Array[InputModeContext] = []
@export var global_controller_context: GUIDEMappingContext
@export var global_kbm_context: GUIDEMappingContext
@export var switch_to_controller_action: GUIDEAction
@export var switch_to_kbm_action: GUIDEAction


func _ready() -> void:
	if switch_to_controller_action:
		var controller_mode = GuideState.InputMode.CONTROLLER
		switch_to_controller_action.triggered.connect(_set_input_mode.bind(controller_mode))

	if switch_to_kbm_action:
		var kbm_mode = GuideState.InputMode.KBM
		switch_to_kbm_action.triggered.connect(_set_input_mode.bind(kbm_mode))

	State.Guide.game_mode_changed.connect(_on_game_mode_changed)
	State.Guide.input_mode_changed.connect(_on_input_mode_changed)

	_update_input()


func _set_input_mode(mode: GuideState.InputMode) -> void:
	State.Guide.input_mode = mode


func set_game_mode(mode: String) -> void:
	var mode_exists = false

	for context in input_mode_contexts:
		if context.game_mode == mode:
			mode_exists = true
			break

	if !mode_exists:
		push_error("Cannot set game mode '%s' as it doesn't exist in the contexts array" % mode)
		return

	State.Guide.active_game_mode = mode


func _on_game_mode_changed(_old_mode: String, _new_mode: String) -> void:
	_update_input()


func _on_input_mode_changed(_input_mode: GuideState.InputMode) -> void:
	_update_input()


func _update_input() -> void:
	var active_game_mode = State.Guide.active_game_mode
	if active_game_mode.is_empty():
		return

	var game_mode_context = null

	for context in input_mode_contexts:
		if context.game_mode == active_game_mode:
			game_mode_context = context
			break

	if game_mode_context == null:
		var error_message = "No context found for game mode '%s'"
		push_error(error_message % active_game_mode)
		return

	match State.Guide.input_mode:
		GuideState.InputMode.KBM:
			if global_kbm_context != null:
				GUIDE.enable_mapping_context(global_kbm_context, true)
			else:
				push_error("Global KBM context is null")

			if game_mode_context.kbm_context != null:
				GUIDE.enable_mapping_context(game_mode_context.kbm_context)
			else:
				var warning_message = "KBM context for game mode '%s' is null"
				push_warning(warning_message % active_game_mode)

		GuideState.InputMode.CONTROLLER:
			if global_controller_context != null:
				GUIDE.enable_mapping_context(global_controller_context, true)
			else:
				push_error("Global controller context is null")

			if game_mode_context.controller_context != null:
				GUIDE.enable_mapping_context(game_mode_context.controller_context)
			else:
				var warning_message = "Controller context for game mode '%s' is null"
				push_warning(warning_message % active_game_mode)
