class_name InteractTarget
extends Area2D

# An interactable hotspot: registers its registration with the
# InteractionService while a probe overlaps, and forwards the GUIDE trigger
# (ACTION mode) or fires immediately on entry (ENTER mode). Ported from
# trail-and-error.

enum TriggerMode { ACTION, ENTER }

@export var mode: TriggerMode = TriggerMode.ACTION
@export var trigger: GUIDEAction

# An optional second action that fires this target identically to trigger — so
# a hotspot can be driven by two inputs without either becoming a general
# interact. The dispatch fires the focused target once per physics frame, so
# both in the same frame cannot double-fire.
@export var alt_trigger: GUIDEAction

# Nudge for this target's PROMPT only — the focus anchor is unmoved.
@export var prompt_offset := Vector2.ZERO

var registration: InteractionRegistration

var _is_registered := false

@onready var _service: InteractionService = Provider.inject(self, InteractionService)


func _init() -> void:
	collision_layer = CollisionLayers.INTERACTABLE
	collision_mask = CollisionLayers.INTERACTABLE


func _ready() -> void:
	if mode == TriggerMode.ACTION and trigger == null:
		push_error("A trigger action is required for ACTION-mode interactables.")

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _exit_tree() -> void:
	_cleanup()


func set_interaction_enabled(value: bool) -> void:
	set_deferred("monitorable", value)
	set_deferred("monitoring", value)


func _on_area_entered(area: Area2D) -> void:
	if area is not InteractProbe or registration == null:
		return

	# Tell the registration which action fires it, so the prompt shows the right
	# input glyph (ACTION mode only; ENTER mode has no key), and where to draw it.
	registration.trigger = trigger if mode == TriggerMode.ACTION else null
	registration.prompt_offset = prompt_offset

	_service.register(registration)
	_is_registered = true

	if mode == TriggerMode.ACTION:
		if trigger != null:
			trigger.triggered.connect(_on_trigger_fired)

		if alt_trigger != null:
			alt_trigger.triggered.connect(_on_trigger_fired)
	elif mode == TriggerMode.ENTER:
		_service.notify_triggered(registration)


func _on_area_exited(area: Area2D) -> void:
	if area is not InteractProbe:
		return

	_cleanup()


func _cleanup() -> void:
	if not _is_registered or registration == null:
		return

	if mode == TriggerMode.ACTION:
		if trigger != null and trigger.triggered.is_connected(_on_trigger_fired):
			trigger.triggered.disconnect(_on_trigger_fired)

		if alt_trigger != null and alt_trigger.triggered.is_connected(_on_trigger_fired):
			alt_trigger.triggered.disconnect(_on_trigger_fired)

	_service.unregister(registration)
	_is_registered = false


func _on_trigger_fired() -> void:
	# Ignore an edge that a mapping-context swap manufactured rather than the
	# player playing it: GUIDE can raise triggers for actions it hands back
	# inside the frame a context changes (guard ported from trail-and-error).
	if registration == null or Engine.get_physics_frames() == GuideState.last_context_change_frame:
		return

	_service.notify_triggered(registration)
